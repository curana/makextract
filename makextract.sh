#!/bin/tcsh -f

# (c) Benedikt Niessen, 2013
#
# DESCRIPTION: Extracts all used make options from installed ports
#

# Copy /etc/make.conf to the current directory
cp /etc/make.conf .

if (`whereis -q pkg` == "") then                     
        # Extract the ports origin via pkg_info
        echo "Info: Using pkg_info"
        set ports = `pkg_info | awk '{ system("pkg_info -oq " $1) }' | awk '{ print("/usr/ports/"$1) }'`
else                                              
        # Extract the ports origin via pkg info (pkgng)
        echo "Info: Using pkgng"
        set ports = `pkg info | awk '{ system("pkg info -oq " $1) }' | awk '{ print("/usr/ports/"$1) }'`
endif

# Extract the used options from each port
foreach elem ($ports:q)
    set config = `echo ${elem:q} | awk '{ system("cd "$1 "&& make showconfig") }'`

    # Only handle ports with options
    if ("x${config}" != "x") then
    	set unique = `cd ${elem:q} && make -V OPTIONS_NAME`       # Reads the unique-Port-Identifier for make
        set unique_set = "${unique}_SET="                       # Prepare the _SET list, eg. nginx_SET=
        set unique_unset = "${unique}_UNSET="                   # Prepare the _UNSET list, eg. nginx-UNSET=

        # Add discovered options to the list
        foreach elem ($config:q)
        	# Handle options which have been set to "ON"
            if ($elem:q =~ *=on*:) then
            	set option = `echo ${elem:q} | awk -F "=" '{ print $1 }'`       # Extract the option's name
                set unique_set = "${unique_set} ${option}"                      # Add the option to the list

                # Handle options which have been set to "OFF"
            else if ($elem:q =~ *=off*:) then
                set option = `echo ${elem:q} | awk -F "=" '{ print $1 }'`       # Extract the option's name
                set unique_unset = "${unique_unset} ${option}"                  # Add the option to the list
            endif
        end

        # Write the lists only if parameters were found and set
        if ("${unique_set}" != "${unique}_SET=" || "${unique_unset}" != "${unique}_UNSET=") then
        	# Write a separator
            echo >> make.conf
            echo "# Options for ${unique}:" >> make.conf

            if ("${unique_set}" != "${unique}_SET=") then
            	echo ${unique_set} >>  make.conf
            endif
            if ("${unique_unset}" != "${unique}_UNSET=") then
                echo ${unique_unset} >>  make.conf
            endif
        endif

        # Clean up
        unset option unique unique_set unique_unset
    endif
end
