# zospm
_zospm_ is an experimental idea for z/OS package management.

_zospm_ lets you search, secure, install and configure software on z/OS using a prescriptive approach, 
especially with respect to naming conventions for the software. 

***zospm Development Philosophy***

1. Automation is paramount. The only way to achieve drastic time reduction is through automation
2. Since our philosophy is to work with an automated, prescriptive approach, zospm must define it's own set of 
_Best Practices for z/OS Automated Software Installation_ and Configuration to achieve #1  
3. _zospm_ will not be useful with an all-or-nothing approach. _zospm_ needs to interact with traditional 
software installation and configuration
4. _zospm_ needs feedback to ensure these _Best Practices_ can be applied to real-world shops

***zospm Divide and Conquer Model***

z/OS is a complex, multi-tenant, multi-application operating system responsible for running the world's largest businesses. 
As such, installing and configuring software can require multiple people to be involved in the process along with 
product-specific installation requirements. In addition, it is critical that z/OS software installation and configuration
be automated so that the specialized skills of systems programmers can be used for higher level tasks rather than mundane 
and error prone manual installation and configuration. Finally, with the emergence of stand-alone dev/test environments 
for use by individuals or small teams, the need for simple, automated installation of z/OS software on these systems 
without the need for systems programmers is becoming more critical. 

_zospm_ tackles these issues by providing services for common functions (like receiving and applying software from ShopZ), 
and delegating product specific function to the products in question. There are 3 functions that _zospm_ delegates 
to the underlying product:

- **Prerequisites Checking**: products require other software to function correctly. Before installing the software,
a check needs to be made that the products are available, configured correctly, and with the right level of maintenance.
- **Secure**: products require security changes to be made to function correctly. The security updates would typically 
be performed by a different person on a production system (TBD... not yet in the code base)
- **Installation**: products require datasets to be allocated and zFS directories to be created before an SMP/E apply 
can be performed. 
- **Configuration**: products need to be configured after the software is installed. This configuration step may be as 
simple as running an installation verification program (IVP), but in general, there are quite a few things required to
configure software

***How to install zospm:***

*From github*
You can download zospm from github directly into _ZOSPMROOT_. You will need to 'build' zospm before you can use it. To do so:
- cd _ZOSPMROOT_
- cd ..
- git clone git@github.com:zospm/zospm.git
- cd _ZOSPMROOT_/build
- ./build.sh

*From bintray*
You can also get zospm from bintray: https://bintray.com/zospm/zospm
To install from bintray:
- Download the pax file from bintray to your desktop, then upload via sftp to _ZOSPMROOT_
- Log on to z/OS
- mkdir _ZOSPMROOT_
- cd _ZOSPMROOT_
- pax -rf zospm_yyyymmddhhmm.pax

You will then want to pick up pax files for each software package you want to install. 
Start with _zospm-zhw_, which is just a hello world package, to ensure it all works. Install all pax files in the _ZOSPM\_WORKROOT_ directory. 

If you want to look at any of the source for zospm, go to:
- https://github.com/zospm/zospm
There are corresponding git repos for the software packages which have a -<sw> after them, e.g.
- https://github.com/mikefultonbluemix/zospm-eqa

***How to run zospm:***

The zospm program resides in _ZOSPMROOT/bin_ directory. You can either run the program with the fully qualified name or you can put the _ZOSPMROOT/bin_ directory into your PATH. The instructions that follow assume it is in your PATH. 
You need to specify a zospm work root directory that zospm can read properties from and that it can write results to. You can either export the environment variable: _ZOSPM\_WORKROOT_ or you can specify the zospm work root directory with the -w option on the zospm command line.

If you do not know the name of the product, issue:
- zospm search _string_
e.g.
- zospm search debug
which will then tell you that debug is _eqae20_ (EQA 14.2.0)

To install a product, you will need the ORDER JSON file for that product. 
Currently, we support products:
- ordered from ShopZ
- ordered from Passport Advantage
- in the local zFS file system
All ORDER files go into a directory you create called _ZOSPM\_WORKROOT/order_ 
The name of the ORDER file is: 
- _sw_ order.json
e.g.
- _zhw110order.json_

*For ShopZ:*
- Go into ShopZ and order your CBPDO software as you normally would. You will be send information on how to install, along with a file called _rfnjobs.txt_
- Copy this file to z/OS under _/tmp/rfnjobs.txt_, then issue:
- _ZOSPMROOT/utils/shopzgenorder sw </tmp/rfnjobs.txt >ZOSPM_WORKROOT/*sw*order.json_, where _sw_ is the software you are installing, e.g. eqae20

*For Local zFS file system*
- Only zhw110 has been created as a local zFS product. The ORDER file for _zhw110order.json_ is:
```
{
 	"software": [{
		"name":"ZHW110",
		"order":{
			"SMPE_DELIVERY":"LOCAL"
                 }
	}]
}
```


To run zospm to install and configure a particular software package, issue:
- export ZOSPM_WORKROOT=<root>
- Set up your order, pkg, and props directories
- zospm install _sw_
- zospm configure _sw_
e.g. to install and configure zhw110 using the ADCD V24 system configuration:
- export ZOSPM_WORKROOT=$HOME/zospmwork
- mkdir ${ZOSPM_WORKROOT}/props
- cp ${ZOSPMROOT}/zospm/zospmglobalprops_ADCDV24.props ${ZOSPM_WORKROOT}/props
- zospm install zhw110
- zospm configure zhw110

***zospm Package Provider Services***

Work needs to be done to provide a clean separation of services used by zospm itself, and services that can be used by package providers developing their software.

With the previous caveat in mind, here is a current list of services that package providers can use:
- Z Open Automation Utility (ZOAU) Services: zospm itself requires ZOAU and therefore it is reasonable for package providers to leverages these services as well
- Shell Functions from _zospmfuncs_:
   - you can use most of the functions in _zospmfuncs_ by sourcing _zospmfuncs_ from a z/OS shell environment (but not  another shell such as bash). Most of these are not complex functions, but may save you some coding:
   - documentation is still lacking, but the services include: 
      - a2e, e2a : convert a file, in place from ISO8859-1 code page to IBM-1047 (or vice-versa)
      - zospmprops, zospmpropse : read a JSON file of key/value pairs and export the corresponding set of environment variables
      - zospmswinstalled : determine if a particular piece of software is installed
      - issueTSO : issue a TSO command and route errors to stderr
      - chk : handy routine for checking a return code and printing out a corresponding message and exiting if the return code is non-zero
      - isinteger : true if the value is integral, false otherwise
      - definedProperty / undefinedProperty : services that check if a value is defined or not. zospm treats values that are '' or NONE as not defined, otherwise they are defined.
      - racfUserExists, racfGroupExists, racfProfileExists : wrapper routines to perform basic RACF existance checks
      - racfPermitUsers, racfActivateAndShareClasses, racfSetGenericClasses, racfRefreshClasses, racfSubjectsDN : wrapper routines to perform basic RACF operations
      - jclAddDatasetToDD, jclRemoveDD, jclReplaceDD : add, remove or replace the contents of a DD statement in a JCL stream
      - parmlibAddDataset, parmlibRemoveDataset : add or remove a dataset from the active PARMLIB concatenation
      - llaAddDatasets, llaRemoveDatasets : add or remove datasets from the active LLA
      - supportsCICS : target environment supports CICS
      - stopCICS, startCICS : start or stop a CICS region
      - vsamexists : returns true if the VSAM cluster exists
      - vsamcp : make a copy of a VSAM cluster 
      
- you can use the _\*registrar_ shell scripts to enable or disable the active state of a feature, and to make the feature available after IPL
  - apfregistrar: enable or disable an APF authorization for a dataset (perform a dynamic SETPROG APF and update the PROGxx member)
  - procregistrar: enable or disable a new PROCLIB member (perform dynamic JES proclib update and update the PROCLIB dataset member)
  - llregistrar: enable or disable a new dataset in the LLA (perform dynamic LLA update and update the PROGxx member)
  - swregistrar: enable or disable the software specified (update the IFAPRDxx member)
  - ccsdregistrar: enable or disable the CICS CCSD definitions under a GROUP 
  - registrar: general routine to enable or disable text for given software in a PDS member
  - secmgr: return the name of the active security manager on the system
  - zospmsetenv: set up the zospm environment by sourcing this file from a z/OS shell environment (but not another shell such as bash)
  - zospmsetswenv: set up the zospm environment for a particular software package by sourcing this file from a z/OS shell environment (but not another shell such as bash)
