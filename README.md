                 MUltlog 1.10 & iLC 1.1
                 ======================

MUltlog is a system which takes as input the specification of
a finitely-valued first-order logic and produces a sequent 
calculus, a natural deduction system, and clause formation
rules for this logic. All generated rules are optimized
regarding their branching degree. The output is in the form
of a scientific paper written in LaTeX.

iLC is an editor for X-Windows, which allows to specify many-valued
logics for MUltlog in a convenient form.
   
Further information: multlog@logic.at, http://www.logic.at/multlog/

CONTENTS:
1. Requirements
2. Installation
   2.1 Obtaining MUltlog
   2.2 Running the installation script
3. Deinstallation
4. Using MUltlog
   4.1 Guide for the impatient
   4.2 Creating the specification of a logic
   4.3 Creating the paper (DVI)
   4.4 Creating the paper (TeX)
   4.5 Creating the paper (PDF)
5. Documentation
6. Trouble shooting
   6.1 Installation errors
   6.2 Runtime errors
7. About MUltlog


1. Requirements
===============

You need the following packages to run MUltlog:

- MUltlog, available from http://www.logic.at/multlog/

- Some standard Prolog system, e.g. SWI-Prolog from
     http://www.swi.psy.uva.nl/projects/SWI-Prolog/
  Other Prologs should work as well; MUltlog has been
  tested with recent versions of SWI-Prolog and SICStus Prolog.

The packages below are not absolutely necessary, but recommended.

The output of MUltlog is in the form of a LaTeX paper. To view it
properly, you need the typesetting system

- TeX, available from any CTAN ftp server (ftp.dante.de,
  ftp.tex.ac.uk, ctan.tug.org)
  For Unix, the teTeX distribution is particularly convenient
  to install (directory tex-archive/systems/unix/teTeX on CTAN)

- If your TeX distribution does not include pdflatex (unlikely
  with newer TeX distributions) you need "ps2pdf" from the
  "ghostscript" package in order to generate PDF output with
  "lgc2pdf".

MUltlog includes a special editor, iLC, which allows to specify
many-valued logics in a convenient, windows-oriented way, instead
of typing an ASCII text in a strict syntax. To use this editor
you need the script language

- Tcl/Tk (version 7.4/4.0 or later), available from
     ftp://ftp.scriptics.com/pub/tcl/
  Many Unix systems nowadays include Tcl/Tk by default (check for
  a program named "wish").



2. Installation
===============

2.1 Obtaining MUltlog
---------------------

Get the newest release of MUltlog from http://www.logic.at/multlog/.
MUltlog is distributed as gzipped tar-archive. Unpack MUltlog
anywhere with the Unix command
   gunzip -c ml110.tgz | tar xf -
This will create the directory multlog1.10 containing the
installation files.


2.2 Running the installation script
-----------------------------------

As of version 1.05, MUltlog comes with an installation script for
Unix. Before running the script,

- decide which Prolog to use. The script will look for SWI-Prolog,
  SICStus, and BinProlog in some standard locations, and suggest
  the result as a default to the user.

- decide where to put MUltlog. The default locations are
  /usr/local/bin for executables, /usr/local/lib for library files,
  and /usr/local/doc for documentation.
  Note that these directories must exist; the script will not try
  to create them.

To run the installation script, change to the installation directory
multlog-1.10 and type
  ./ml_install
The script will
- determine the location of some Unix commands
- ask the user for the Prolog to use
- ask the user for the place where to put MUltlog
- generates the deinstallation script "ml_deinstall"
- insert the correct paths in some of MUltlog's files
- copy MUltlog in its place
This step completes the installation. In case of problems
see the section on trouble shooting below.

Note that the installation procedure puts path information directly
into some of MUltlog's files. This means that to install MUltlog
somewhere else, you need the original distribution as well as
the installation script.



3. Deinstallation
=================

Run the script
   ml_deinstall
to remove files installed by "ml_install". The deinstallation
script is located in the same directory as the other MUltlog
commands like "lgc2tex", "lgc2dvi", ...  (/usr/local/bin by default).



4. Using MUltlog
================

The examples below assume that MUltlog was installed into
the standard place /usr/local/*, and assumes that /usr/local/bin
is on your command path. If you use different settings, change
the examples accordingly.


4.1 Guide for the impatient
---------------------------

- Move to a temporary directory
    mkdir tmp; cd tmp
- Get a sample logic
    cp /usr/local/doc/multlog/goedel.lgc .
- Generate the paper in DVI format
    lgc2dvi goedel
  and view it:
    xdvi goedel &
  Or generate the paper in PDF format
    lgc2pdf goedel
  and view it with any PDF reader, e.g.
    acroread goedel.pdf &
    ghostview goedel.pdf &
    ...

- To edit the specification of the logic before generating
  the paper, type
    ilc &
  Select "Open" from the menu "File" and type "goedel"
  as the name of the file to be loaded.


4.2 Creating the specification of a logic
-----------------------------------------

You can either use your favourite text editor, or the "interactive
Logic Creator" ilc.

In the first case specify your many-valued logic in the syntax
described in the sample specification "/usr/local/doc/multlog/goedel.lgc"
and save the result as "<name>.lgc".

To start ilc, type
   ilc &
A window pops up, and you are able to edit a new logic or re-edit
an already exisiting one, and to save the result in a textual format
suitable for MUltlog. Note that you have to store the logic as
"<name>", the extension ".lgc" being added automatically.


4.3 Creating the paper (DVI)
----------------------------

To obtain the paper corresponding to your logic, type
   lgc2dvi <name>
where <name> is the name under which you saved your logic.
This invokes MUltlog as well as LaTeX and BibTeX. Additionally,
all files are deleted except the specification of the logic and
the DVI file.

View the resulting paper with
   xdvi <name> &


4.4 Creating the paper (TeX)
----------------------------

If you are interested in the TeX source of the paper,
use lgc2tex instead of lgc2dvi:
   lgc2tex <name>
This will invoke MUltlog, but does neither latexing nor
cleaning up.


4.5 Creating the paper (PDF)
----------------------------

To obtain the paper corresponding to your logic, type
   lgc2pdf <name>
where <name> is the name under which you saved your logic.
This invokes MUltlog as well as PDFLaTeX and BibTeX (or
alternatively, if pdflatex was not found upon installation,
LaTeX, BibTeX, dvips and ps2pdf).
Additionally, all files are deleted except the specification
of the logic and the PDF file.

View the resulting paper with any PDF reader, e.g.
    acroread goedel.pdf &
    ghostview goedel.pdf &
    ...



5. Documentation
================

Unfortunately, there is only very little documentation around.
The directory "/usr/local/doc/multlog" (or whatever you chose)
contains most of it.

- goedel.lgc
  ASCII text. It describes the input syntax of MUltlog, and
  at the same time serves as a sample input for MUltlog,
  specifying the three-valued Goedel logic.

- goedel.cfg
  ASCII text. Specifies the translation of operators and
  quantifiers to TeX commands. Not necessary (there are
  defaults), only for beautifying the TeX output.
  Serves as an example how such a file has to be written.

- mlsys.pdf
  Draft of system description of MUltlog published at CADE-96.

iLC should be rather self-explanatory once you know what
a many-valued logic is; additionally, you can read goedel.lgc
to get an idea what the various options mean.



6. Trouble shooting
===================

6.1 Installation errors
-----------------------

The installation script may produce the following warnings
and errors.

- "Error: <directory> does not exist."
  The installation script did not find the directory for
  executables, library, or documentation (/usr/local/bin,
  /usr/local/lib, and /usr/local/doc by default).
  Create the directories before running the script.

- "Error: could not find Unix command <command>."
  where <command> is one of
     basename chmod cp dirname false grep mkdir pwd rm sed true.
  The installation script and the scripts for starting
  MUltlog (lgc2tex, lgc2dvi, lgc2pdf, and lgc2ilc) need these Unix commands.
  The error message means that <command> could not be located,
  neither on the current command search path nor in the directories
     /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin.
  Locate the directory containing <command> and put it on your
  command search path during installation.

  If your Unix system does not have <command> at all, send a bug
  report to MUltlog@logic.at.

- "Warning: could not find TeX command <command>."
  where <command> is one of
     latex bibtex.
  The script "lgc2dvi" needs latex and bibtex to produce a DVI-file
  from the TeX document created by MUltlog. The warning means that
  <command> could not be located, neither on the current command
  search path nor in the directories
     /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin.
  Check whether TeX is properly installed and put the directory
  containing <command> on your command search path during
  installation.

- "Warning: couldn't find any PDF converters."
  The script "lgc2pdf" needs either pdflatex or latex & dvips & ps2pdf
  to produce a PDF-file from the TeX document created by MUltlog.
  The warning means that either pdflatex or dvips or ps2pdf
  could not be located, neither on the current command
  search path nor in the directories
     /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin.
  Check whether TeX and Ghostscript are properly installed and put
  the directory containing the PDF converter on your command search path
  during installation.

- "Warning: could not find Tcl/Tk command wish."
  The editor "ilc" needs the Tcl/Tk package, in particular the
  program "wish". The warning means that "wish" could not be located,
  neither on the current command search path nor in the directories
     /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin.
  Check whether Tcl/Tk is properly installed and put the directory
  containing "wish" on your command search path during installation.

- "Error: <command> does not exist or has no execute permission."
  <command> (suggested by the user as Prolog interpreter) does
  not exist or cannot be executed.
 
- "Error: <command> does not behave like Prolog."
  <command> (suggested by the user as Prolog interpreter)
  exists but fails the test performed by the installation
  script. This test is a heuristic check whether <command>
  is indeed a Prolog system; more precisely, the output of
     echo 'f(X,not)=f(ger,Y), print(X),print(Y),halt.' | <command>
  is checked for the string "gernot".
  If <command> is a Prolog system but fails this test,
  or if it is no Prolog system but passes the test,
  send a bug report to MUltlog@logic.at.



6.2 Runtime errors
------------------

- "warning: *** copy_term overflow in findall_store_heap ***"
  "warning: *** overflow in findall_store_heap ***"
  These error messages are produced by BinProlog and indicate that
  the heap size is too small, which by default is 512 kB.
  (Reported by Matthew Spinks <mspinks@mugc.cc.monash.edu.au>.)

  Solutions (alternatives):
   o Switch to SWI Prolog which is faster and more robust.
     Available from ftp://swi.psy.uva.nl/pub/SWI-Prolog and 
     http://www.logic.at/MUltlog.
     You will have to re-install Multlog after SWI-Prolog is
     in its place.
   o Re-install MUltlog using BinProlog with the option "-h 1024"
     (or some bigger value). When the installation script asks for
     the Prolog to be used, type e.g.
       /usr/local/bin/bp -h 1024
     Note that adding options to the Prolog call only works with
     MUltlog 1.06 or higher.
   o Add the option "-h 1024" by hand.
     To this aim, edit the files
        /usr/local/bin/lgc2tex
        /usr/local/bin/lgc2dvi
        /usr/local/bin/lgc2pdf
        /usr/local/lib/multlog/ilc/lgc2ilc
     Near their top there is a line starting with "PROLOG=".
     Replace this line e.g. by
        PROLOG='/usr/local/bin/bp -h 1024'
     Make sure that the files have still execute permission
     after saving.



7. About MUltlog
================

The following people contributed to MUltlog (in alphabetical order):

Stefan Katzenbeisser ... rewrote the optimization procedure for
                         operators using more efficient data structures
                         together with Stefan Kral
Stefan Kral ............ see Stefan Katzenbeisser
Andreas Leitgeb ........ author of iLC, the interactive Logic Creator
Wolfram Nix ............ author of eLK, a DOS interface to MUltlog
Alexandra Pascal ....... author of JMUltlog, a JAVA interface to MUltlog
Gernot Salzer .......... author of the MUltlog kernel
                         and coordinator of the project.
Markus Schranz ......... author of a web interface to MUltlog based
                         on plain HTML and Perl



Vienna, July 11, 2001                 Gernot Salzer, salzer@logic.at