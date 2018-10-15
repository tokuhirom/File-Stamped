requires 'perl', '5.008001';

on build => sub {
    requires 'Test::More', '0.98';
};

on configure => sub {
    requires 'Module::Build::Tiny', '0.039';
};
