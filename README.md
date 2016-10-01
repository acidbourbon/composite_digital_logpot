The idea is the following:

We want a digital logarithmic potentiometer but we don't have one.
Let us build one out of two linear potentiometers! (We put them in series.)

The GNU Octave script "calc_lookup.m" calculates a set of wiper settings combinations
for both potentiometers which make the combined circuit act like a logarithmic potentiometer.

Linux users:
  Install GNU Octave with your usual package manager, e.g.
  sudo apt-get install octave
  
  Open a terminal, "cd" to the folder containing calc_lookup.m and call the script by typing
  "octave calc_lookup.m"
  It generates several plots and a look-up table in csv format.
  
Windows users:
  You can use Cygwin, which is a Linux like software distribution. (https://cygwin.com/install.html)
  In the install wizard search and mark the package "octave" for installation.
  Then open the cygwin terminal, "cd" to the folder containing calc_lookup.m and call the script
  by typing:
  "octave calc_lookup.m"
  It generates several plots and a look-up table in csv format.


Go to http://acidbourbon.wordpress.com/2016/10/01/brute_force_logpots
to read the full details about this and other projects.

2016 by Michael Wiebusch