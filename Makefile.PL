use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::ReadmeMarkdownFromPod;

name 'File-Stamped';
all_from 'lib/File/Stamped.pm';
readme_markdown_from 'lib/File/Stamped.pm';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
