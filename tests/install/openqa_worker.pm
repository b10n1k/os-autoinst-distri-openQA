use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    diag('worker setup');
    disable_packagekit;
    assert_script_run('retry -e -s 30 -r 7 -- sh -c "zypper -n --gpg-auto-import-keys ref && zypper --no-cd -n in openQA-worker"', 3800);
    diag('Login once with fake authentication on openqa webUI to actually create preconfigured API keys for worker authentication');
    assert_script_run('curl http://localhost/login');
    diag('adding temporary, preconfigured API keys to worker config');
    type_string('cat >> /etc/openqa/client.conf <<EOF
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
');
    assert_script_run('os-autoinst-setup-multi-machine');
    my $worker_setup = <<'EOF';
systemctl start openqa-worker@1
systemctl status --no-pager openqa-worker@1
systemctl enable openqa-worker@1
EOF
    assert_script_run($_) foreach (split /\n/, $worker_setup);
    save_screenshot;
    clear_root_console;
}

1;
