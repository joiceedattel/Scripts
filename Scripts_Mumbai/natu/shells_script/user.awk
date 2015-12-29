awk ' BEGIN{ FS=":"; }
{
	if ( $3 > 500 )
		{ printf $1;printf "\n"; }
	else
		{ printf $3; printf ": system user\n"; }
}
END{ }' /etc/passwd
