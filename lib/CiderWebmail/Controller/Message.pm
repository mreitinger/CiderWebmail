package CiderWebmail::Controller::Message;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

CiderWebmail::Controller::Message - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched CiderWebmail::Controller::Message in Message.');
}

sub view : Local {
    my ( $self, $c, $mailbox, $uid ) = @_;
    my $model = $c->model();

    my $message = $c->model->message($c, $mailbox, $uid);

    $c->stash( template => 'message.xml' );
    
    $c->model->select($c, "INBOX");
    $c->stash( folders => [ $model->folders($c) ] );
    $c->stash( message => $message );
}


=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
