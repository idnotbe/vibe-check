"""Adversarial tests of distribution validation, not synthetic model outcomes."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location('distribution', Path(__file__).resolve().parents[1] / 'tools/distribution.py')
distribution = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(distribution)


class DistributionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='distribution test ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bundle = self.root / '.agents/skills/example'
        (self.bundle / 'agents').mkdir(parents=True)
        (self.bundle / 'SKILL.md').write_text('---\nname: example\ndescription: A test skill.\n---\n\nTest.\n', encoding='utf-8')
        (self.bundle / 'agents/openai.yaml').write_text('interface: {}\n', encoding='utf-8')
        self.manifest = {'name': 'example', 'version': '1.0.0', 'description': 'A test skill.',
                         'repository': 'https://github.com/idnotbe/example', 'skills': './.agents/skills/'}
        self.write_manifests()

    def write_manifests(self):
        for relative in distribution.MANIFESTS:
            path = self.root / relative
            path.parent.mkdir(exist_ok=True)
            path.write_text(json.dumps(self.manifest), encoding='utf-8')

    def reject(self):
        with self.assertRaises((ValueError, OSError)):
            distribution.validate(self.root)

    def test_valid_bundle_in_path_with_spaces(self):
        manifest, files = distribution.validate(self.root)
        self.assertEqual(manifest['name'], 'example')
        self.assertEqual(set(files), {'SKILL.md', 'agents/openai.yaml'})

    def test_different_host_manifest(self):
        (self.root / distribution.MANIFESTS[1]).write_text('{}', encoding='utf-8')
        self.reject()

    def test_unsafe_or_noncanonical_paths(self):
        for path in ('../skills', '/skills', 'C:\\skills', './skills/', './.agents/../skills/'):
            with self.subTest(path=path):
                self.manifest['skills'] = path
                self.write_manifests()
                self.reject()

    def test_invalid_release_versions(self):
        for version in ('latest', '1.0', '01.0.0', '', None):
            with self.subTest(version=version):
                self.manifest['version'] = version
                self.write_manifests()
                self.reject()

    def test_wrong_repository_identity(self):
        self.manifest['repository'] = 'https://github.com/other/example'
        self.write_manifests()
        self.reject()

    def test_duplicate_skill(self):
        (self.root / '.agents/skills/duplicate').mkdir()
        self.reject()

    def test_portable_manifest_precedence(self):
        (self.root / 'plugin.json').write_text('{}', encoding='utf-8')
        self.reject()

    def test_duplicate_root_layout(self):
        (self.root / 'skills').mkdir()
        self.reject()

    def test_missing_entrypoint(self):
        (self.bundle / 'SKILL.md').unlink()
        self.reject()

    def test_frontmatter_name_mismatch(self):
        (self.bundle / 'SKILL.md').write_text('---\nname: wrong\ndescription: Test\n---\n', encoding='utf-8')
        self.reject()

    def test_missing_host_metadata(self):
        (self.bundle / 'agents/openai.yaml').unlink()
        self.reject()

    def test_installed_content_mutation_detected(self):
        before = distribution.inventory(self.bundle)
        (self.bundle / 'SKILL.md').write_text('changed', encoding='utf-8')
        self.assertNotEqual(before, distribution.inventory(self.bundle))

    def test_extra_installed_file_detected(self):
        before = distribution.inventory(self.bundle)
        (self.bundle / 'extra.txt').write_text('extra', encoding='utf-8')
        self.assertNotEqual(before, distribution.inventory(self.bundle))

    @unittest.skipIf(os.name == 'nt', 'Invalid Windows names cannot be created natively')
    def test_windows_reserved_name_rejected_on_linux(self):
        (self.bundle / 'CON.txt').write_text('bad', encoding='utf-8')
        self.reject()

    @unittest.skipIf(os.name == 'nt', 'Case-insensitive filesystem cannot create this fixture')
    def test_case_collision_rejected_on_linux(self):
        (self.bundle / 'A.txt').write_text('a', encoding='utf-8')
        (self.bundle / 'a.txt').write_text('b', encoding='utf-8')
        self.reject()

    def test_symlinks_rejected_when_supported(self):
        try:
            (self.bundle / 'link').symlink_to(self.bundle / 'SKILL.md')
        except OSError as exc:
            self.skipTest(str(exc))
        self.reject()


if __name__ == '__main__':
    unittest.main()
