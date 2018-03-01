package ClinEpiData::Load::OntologyDAGNode;
use parent 'Tree::DAG_Node';

use Data::Dumper;

sub format_node {
  my ($self, $options, $node) = @_;

  my $name = $node->{name};
  my $displayName = $node->{attributes}->{displayName};
  my $isLeaf = $node->{attributes}->{isLeaf};

  my $altQualifiers = $node->{attributes}->{alternativeQualifiers};

  my $altQualifiersString = join(",", @$altQualifiers);

  if($isLeaf) {
    return $displayName;
  }
  
  if($altQualifiers) {
    $name = "$name $altQualifiersString";
  }

  if($displayName) {
    return "$displayName ($name)";
  }

  return $name;
}


sub node2string {
  my ($self, $options, $node, $vert_dashes) = @_;

  my $keep = $node->{attributes}->{keep};
  unless($keep) {
    return undef;
  }

  return $self->SUPER::node2string($options, $node, $vert_dashes);
}


sub transformToHashRef {
  my ($self) = @_;

  return unless $self->{attributes}->{keep};

  my $name = $self->{name};
  my $displayName = $self->{attributes}->{displayName};

  $displayName = $name unless($displayName);

  my $hashref = {id => $name, display => $displayName};

  foreach my $daughter (sort { $a->{attributes}->{displayName} cmp $b->{attributes}->{displayName} } $self->daughters()) {
    my $child = $daughter->transformToHashRef();
    push @{$hashref->{children}}, $child if($child);
  }

  return $hashref;
}

sub printNonFilteredAlternativeQualifiers {
  my ($self) = @_;

  return undef if $self->{attributes}->{filter};
  return undef if $self->{attributes}->{isLeaf};
  my $altQualifiers = $self->{attributes}->{alternativeQualifiers};
  if($altQualifiers){
    my $altQualifiersString = join("\n", @$altQualifiers);
    print STDERR "$altQualifiersString\n";
  }

  foreach my $daughter ($self->daughters()) {
    $daughter->printNonFilteredAlternativeQualifiers();
  }

  return undef;
}
1;
