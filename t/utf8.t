use strict;
use warnings;
use Test::More;
use CiderWebmail::Test {login => 1};
use Regexp::Common qw(Email::Address);
use Email::Address;
use English qw(-no_match_vars);

use charnames ':full';

my $uname = getpwuid $UID;

$mech->get_ok('http://localhost/mailbox/INBOX/compose');

my $unix_time = time();

my $body  = "UMLAUT_A_\N{LATIN SMALL LETTER A WITH DIAERESIS} ";
$body    .= "UMLAUT_U_\N{LATIN SMALL LETTER U WITH DIAERESIS} ";
$body    .= "UMLAUT_O_\N{LATIN SMALL LETTER O WITH DIAERESIS} ";
$body    .= "CHECK_\N{CHECK MARK}";

$mech->submit_form(
    with_fields => {
        from        => "$uname\@localhost",
        to          => "$uname\@localhost",
        sent_folder => 'Sent',
        subject     => 'utf8-test-'.$unix_time." -- $body",
        body        => $body,
    },
);

$mech->get( 'http://localhost/mailbox/INBOX?length=99999' );
$mech->content_like(qr/UMLAUT_A_\N{LATIN SMALL LETTER A WITH DIAERESIS}/, 'subject umlaut handling: A');
$mech->content_like(qr/UMLAUT_U_\N{LATIN SMALL LETTER U WITH DIAERESIS}/, 'subject umlaut handling: U');
$mech->content_like(qr/UMLAUT_O_\N{LATIN SMALL LETTER O WITH DIAERESIS}/, 'subject umlaut handling: O');
$mech->content_like(qr/CHECK_\N{CHECK MARK}/, 'subject check mark');


my (@inbox_messages) = $mech->find_all_links( text_regex => qr{\Autf8-test-$unix_time\s\-\-});
ok((@inbox_messages == 1), 'messages found');
$mech->get_ok($inbox_messages[0]->url, 'open message');

$mech->content_like(qr/UMLAUT_A_\N{LATIN SMALL LETTER A WITH DIAERESIS}/, 'body umlaut handling: A');
$mech->content_like(qr/UMLAUT_U_\N{LATIN SMALL LETTER U WITH DIAERESIS}/, 'body umlaut handling: U');
$mech->content_like(qr/UMLAUT_O_\N{LATIN SMALL LETTER O WITH DIAERESIS}/, 'body umlaut handling: O');
$mech->content_like(qr/CHECK_\N{CHECK MARK}/, 'check mark');

$mech->get( 'http://localhost/mailbox/Sent?length=99999' );
my (@sent_messages) = $mech->find_all_links( text_regex => qr{\Autf8-test-$unix_time\s\-\-});
ok((@sent_messages == 1), 'messages found');

$mech->get_ok($inbox_messages[0]->url.'/delete', "Delete message from INBOX");
$mech->get_ok($sent_messages[0]->url.'/delete', "Delete message from Sent folder");

$mech->get_ok( 'http://localhost/mailbox/INBOX?length=99999' );
$mech->content_unlike(qr/utf8-test-$unix_time/, 'message deleted from INBOX');

$mech->get_ok( 'http://localhost/mailbox/Sent?length=99999' );
$mech->content_unlike(qr/utf8-test-$unix_time/, 'message deleted from Sent folder');

done_testing();