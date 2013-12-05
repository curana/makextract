#!/bin/tcsh -f

# (c) Benedikt Niessen, 2013
#
# DESCRIPTION: Extracts all used make options from installed ports
#

set ports = `pkg_info | awk '{ system("pkg_info -o -q " $1) }' | awk '{ print("/usr/ports/"$1) }'`

foreach elem ($ports:q)
	set config = `echo ${elem:q} | awk '{ system("cd "$1 "&& make showconfig") }'`
	
	if ("x$config" != "x") then
		echo '.if ${.CURDIR:M*'${elem:q}'/*}' >> make.conf
	endif

	foreach elem ($config:q)
		if ($elem:q =~ *=*:) then
			set output = `echo ${elem:q} | sed '$s/.$//'` 
			echo "    " $output >> make.conf
		endif
	end

	if ("x$config" != "x") then
		echo ".endif" >> make.conf
	endif
end
