#!/usr/bin/perl

$map = shift;

# Load map (if it exists)
if(open(M, $map))
{
	while($_ = <M>)
	{
		chomp $_;
		($name, $email) = /^(\S+)\s+(.*)$/;
		$map{$name} = $email;
	}
	close M;
}

# Process author list
while($_ = <>)
{
	chomp $_;
	($name, $email) = /^(.*) += +(.*)$/;
	if(defined $map{$name})
	{
		$email = $map{$name};
	}
	print "$name = $email\n";
}
