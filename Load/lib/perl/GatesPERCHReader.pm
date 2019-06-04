package ClinEpiData::Load::GatesPERCHReader;
use base qw(ClinEpiData::Load::MetadataReader);


sub formatdate{
    my ($self,$date) = @_;
    $date =~ s/\//-/g;
    return $date;
}



sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;
}

1;


package ClinEpiData::Load::GatesPERCHReader::HouseholdReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);
use Data::Dumper;
use strict;


sub makeParent {
    my ($self, $hash) = @_;
    return undef;
}


sub makePrimaryKey {
    my ($self, $hash) = @_;
    if(defined $hash->{patid}){
	return $hash->{patid};
    }else{
	return undef;
    }
}


sub getPrimaryKeyPrefix {
    my ($self, $hash) = @_;
    return "HH";
}

1;



package ClinEpiData::Load::GatesPERCHReader::OutputReader;
use base qw(ClinEpiData::Load::OutputFileReader);

1;




package ClinEpiData::Load::GatesPERCHReader::ParticipantReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);
use File::Basename;
use Data::Dumper;


sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}


sub getParentPrefix {
    my ($self, $hash) = @_;
    return "HH";
}

sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;
    my $file =  basename $self->getMetadataFile();

    if(defined($hash->{enrldate})){
            $hash->{enrldate_par} = $hash->{enrldate};
            $hash->{enrldate} = undef;
    }
 }


1;



package ClinEpiData::Load::GatesPERCHReader::ObservationReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);
use File::Basename;
use Data::Dumper;


sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getPrimaryKeyPrefix {
    return "O_";
}


=head
sub makePrimaryKey {
    my ($self, $hash) = @_;  

    if($hash->{enrldate}){
	$hash->{enrldate_obs} = $hash->{enrldate};
	$hash->{enrldate} = undef;
    }

    my $date = $hash->{enrldate_obs};

    $date= $self->formatdate($date);
    return $hash->{patid} . "_" . $date;

}
=cut
sub adjustHeaderArray {
    my ($self, $ha) = @_;
    my $colExcludes = $self->getColExcludes();

    my @visit24hr = grep (/24$/i,@$ha);
    my @visit48hr = grep (/48$/i,@$ha);
    my @visit30days = grep (/^csf|30d$/i,@$ha);
    my @newcolExcludes=(@visit24hr,@visit48hr,@visit30days);
    
#print Dumper \@newcolExcludes;                                                                                                    #exit;                                                                                                                            

    foreach my $newcol (@newcolExcludes){
	$newcol=lc($newcol);
	$colExcludes->{'__ALL__'}->{$newcol}=1;
    }
#print Dumper $colExcludes;                                                                                                       
    return $ha;
}

sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;

    if(defined($hash->{enrldate})){

            $hash->{enrldate_obs} = $hash->{enrldate};
            $hash->{enrldate} = undef;
    }
}

1;




package ClinEpiData::Load::GatesPERCHReader::SubObservationVisit24hrReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);

sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}
sub getParentPrefix {
    my ($self, $hash) = @_;
    return "O_";
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getPrimaryKeyPrefix {
    return "visit24h_";
}

=head
sub makePrimaryKey {
    my ($self, $hash) = @_;  

    my $date= $hash->{cfuvisdt24};
    $date= $self->formatdate($date);
    return $date ? $hash->{patid} . "_" . $date . "_" . "24hr" : $hash->{patid} . "_" . "24hr";

}
=cut
sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;

    if(defined($hash->{enrldate})){

            $hash->{enrldate_obs} = $hash->{enrldate};
            $hash->{enrldate} = undef;
    }
}



1;
=head
sub makeParent {
    my ($self, $hash) = @_;  

    if(defined($hash->{enrldate})){
	$hash->{enrldate_obs} = $hash->{enrldate};
	$hash->{enrldate} = undef;
    }

    my  $date=$hash->{enrldate_obs};

    $date= $self->formatdate($date);
    return $date ? $hash->{patid} . "_" . $date : $hash->{patid};

}

sub makePrimaryKey {
    my ($self, $hash) = @_;  

    if(defined($hash->{cfuvisdt24})){
	$hash->{cfuvisdt24} = $hash->{cfuvisdt24};
    }

    my $date= $hash->{cfuvisdt24};
    $date= $self->formatdate($date);
    return $date ? $hash->{patid} . "_" . $date . "_" . "24hr" : $hash->{patid} . "_" . "24hr";

}
=cut

=head
sub makePrimaryKey {
    my ($self, $hash) = @_;

    my $date;
    if (defined $hash->{cfuvisdt24}){
        $date=$hash->{cfuvisdt24};
    }
    else {
        die 'Could not find the visit24hr date';
    }

    $date= $self->formatdate($date);
    return $hash->{patid} . "_" . $date . "_" . "24hr";
}

sub adjustHeaderArray {
    my ($self, $ha) = @_;
    my $colExcludes = $self->getColExcludes();

    my @visit48hr = grep (/48$/i,@$ha);
    my @visit30days = grep (/^csf|30d$/i,@$ha);
    my @newcolExcludes=(@visit48hr,@visit30days);
    
    print Dumper \@newcolExcludes;                                                                                                    exit;                                                                                                                            

    foreach my $newcol (@newcolExcludes){
	$newcol=lc($newcol);
	$colExcludes->{'__ALL__'}->{$newcol}=1;
    }
    return $ha;
}

=cut




package ClinEpiData::Load::GatesPERCHReader::SubObservationVisit48hrReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);

sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}
sub getParentPrefix {
    my ($self, $hash) = @_;
    return "O_";
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getPrimaryKeyPrefix {
    return "visit48h_";
}

sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;

    if(defined($hash->{enrldate})){

            $hash->{enrldate_obs} = $hash->{enrldate};
            $hash->{enrldate} = undef;
    }
}



1;


package ClinEpiData::Load::GatesPERCHReader::SubObservationVisit30dayReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);

sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}
sub getParentPrefix {
    my ($self, $hash) = @_;
    return "O_";
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getPrimaryKeyPrefix {
    return "visit30d_";
}

sub cleanAndAddDerivedData {
    my ($self, $hash) = @_;

    if(defined($hash->{enrldate})){

            $hash->{enrldate_obs} = $hash->{enrldate};
            $hash->{enrldate} = undef;
    }
}

1;


=head

package ClinEpiData::Load::GatesPERCHReader::SampleReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);
use File::Basename;
use Data::Dumper;

sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{??????};
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    my $date;
    if (defined $hash->{????????}){
        $date=$hash->{??????????};
    }
    else {
        die 'Could not find the ??????  date';
    }

    $date= $self->formatdate($date);
    return $hash->{patid} . "_" . $date;
}

1;
=cut

package ClinEpiData::Load::GatesPERCHReader::SampleReader;
use base qw(ClinEpiData::Load::GatesPERCHReader);
use File::Basename;
use Data::Dumper;

sub makeParent {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getParentPrefix {
    return "O_";
}

sub makePrimaryKey {
    my ($self, $hash) = @_;
    return $hash->{patid};
}

sub getPrimaryKeyPrefix {
    return "Sample_";
}
