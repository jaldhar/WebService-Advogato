package WebService::Advogato;

use Carp;
use RPC::XML ':types';
use RPC::XML::Client;
use strict;
use vars qw($VERSION);

$VERSION = '1.00';

#
# $Id: Advogato.pm,v 1.1 2003/04/11 18:21:48 jaldhar Exp $
#

sub new()
{
  my ($proto, $user, $pass) = @_;

  my $class = ref($proto) || $proto;
  my $self = {
    'client' => RPC::XML::Client->new('http://www.advogato.org/XMLRPC'),
    'user' => $user || '',
    'pass' => $pass || '',
  };
  bless($self, $class);
  return $self;
}

sub _authenticate()
{
  my ($self) = @_;

  my $result = $self->{'client'}->send_request('authenticate', 
    RPC_STRING($self->{'user'}), RPC_STRING($self->{'pass'}));
  croak $result unless ref $result;
  croak $result->code . ': ' . $result->string 
    if ref $result eq 'RPC::XML::fault';
  $self->{'cookie'} = $result->value;
}

sub _call()
{
  my ($self, $method, @args) = @_;

  my $ result = $self->{'client'}->send_request($method, @args);  
  croak $result unless defined($result);
  croak $result->code . ': ' . $result->string if $result->is_fault;
  return $result->value;
}

sub capitalize($)
{
  my ($self, $x) = @_;

  return $self->_call('test.capitalize', RPC_STRING($x));
}

sub get($$)
{
  my ($self, $user, $index) = @_;

  return $self->_call('diary.get', RPC_STRING($user), RPC_INT($index));
}

sub getDates($$)
{
  my ($self, $user, $index) = @_;

  return @{$self->_call('diary.getDates', RPC_STRING($user), RPC_INT($index))};
}

sub guess()
{
  my ($self) = @_;

  return @{$self->_call('test.guess')};
}

sub len($)
{
  my ($self, $user) = @_;

  return $self->_call('diary.len', RPC_STRING($user));
}

sub set($$)
{
  my ($self, $index, $html) = @_;

  $self->_authenticate() unless $self->{'cookie'};
  return $self->_call('diary.set', RPC_STRING($self->{'cookie'}),
    RPC_INT($index), RPC_STRING($html));
}

sub square($)
{
  my ($self, $x) = @_;

  return $self->_call('test.square', RPC_INT($x));
}

sub strlen($)
{
  my ($self, $str) = @_;

  return $self->_call('test.strlen', RPC_STRING($str));
}

sub sumprod($$)
{
  my ($self, $x, $y) = @_;

  return @{$self->_call('test.sumprod', RPC_INT($x), RPC_INT($y))};
}

1;

__END__

=head1 NAME

WebService::Advogato - XML-RPC interface to www.advogato.org

=head1 SYNOPSIS

 use WebService::Advogato;
 my $client = new WebService::Advogato('username', 'password');
 my $num_entries = $client->len('jaldhar');
 $client->set(-1, '<p>A diary entry.</p>');

=head1 ABSTRACT

This module implements the XML-RPC interface to the diaries at www.advogato.org
a site for developers of free software.

=head1 DESCRIPTION

The module is implemented as a class.  The methods use standard perl scalars
and arrays but internally they use XML-RPC datatypes:  int, string and date.
The following descriptions include the datatype for your reference.

=head2 Constructor

An object is constructed using the standard syntax.  The constructor can take
two parameters: I<username>, and I<password> which are the name and password
of an advogato user account.  These are used in methods which require logging
in.

=head2 Diary manipulation methods

=over 4

=item $int_length = len($string_user)

Return the number of entries in a diary.

=item $string_html = get($string_user, $int_index)

Return a diary entry. The index is zero-based, so if I<len> returns 2
then valid indices are 0 and 1.

=item ($date_created, $date_updated) = getDates($string_user, $int_index)

Return the creation and last updated dates of a diary entry. If the entry
has not been updated then the updated date will be the same as the
creation date.

=item set($int_index, $string_html)

Set a diary entry. Use -1 as the index to post a new entry, although the
value returned by I<len> is also acceptable.

=back

=head2 Test methods

These methods are only useful for testing purposes.

=over 4

=item $string_capitalized = capitalize($string)

Capitalize a string

=item ($string, $int) = guess()

Guess a number.  (Actually always returns 'You guessed' and 42.)

=item $int = square($int)

Square a number.

=item ($int_sum, $int_product) = sumprod($int_x, $int_y)

Return the sum and product of a pair of numbers

=item $int_len = strlen($string)

Return the length of a string

=back

=head1 SEE ALSO

L<http://www.advogato.org/xmlrpc.html>

=head1 AUTHOR

Jaldhar H. Vyas, E<lt>jaldhar@braincells.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2003, Consolidated Braincells Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

