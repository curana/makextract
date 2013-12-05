#!/bin/tcsh -f

# (c) Benedikt Niessen, 2013
#
# DESCRIPTION: Extracts all used make options from installed ports
#

# Copy /etc/make.conf to the current directory
cp /etc/make.conf .

# Extract the ports origin via pkg_info
set ports = `pkg_info | awk '{ system("pkg_info -o -q " $1) }' | awk '{ print("/usr/ports/"$1) }'`

# Extract the used options from each port
foreach elem ($ports:q)
	set config = `echo ${elem:q} | awk '{ system("cd "$1 "&& make showconfig") }'`
	
	# Skip ports without options
	if ("x$config" != "x") then
		echo '.if ${.CURDIR:M*'${elem:q}'/*}' >> make.conf
	endif
	
	# Write discovered options to local make.conf
	foreach elem ($config:q)
		if ($elem:q =~ *=*:) then
			set output = `echo ${elem:q} | sed '$s/.$//'` 
			echo "    " $output >> make.conf
		endif
	end

	# Skip ports without options
	if ("x$config" != "x") then
		echo ".endif" >> make.conf
	endif
end
