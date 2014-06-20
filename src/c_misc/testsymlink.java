
/***
https://issues.jenkins-ci.org/browse/JENKINS-23234?focusedCommentId=202596#comment-202596
Regular cvs behaviour (generally but upon update in particular) is to ignore symlinks.
See function special_file_mismatch in update.c (and function islink in filesubr.c) in cvs source code.
http://cvs.savannah.gnu.org/viewvc/cvs/ccvs/src/update.c?revision=HEAD&view=markup


https://github.com/jenkinsci/cvs-plugin/blob/master/src/main/java/hudson/scm/AbstractCvs.java
Nope. Can't do it in CVS Plugin
CVS Plugin just uses netbeans cvs lib.

https://versioncontrol.netbeans.org/javacvs/library/
http://hg.netbeans.org/core-main/file/0361f0f86dbb/lib.cvsclient/src/org/netbeans/lib/cvsclient/command/update
http://hg.netbeans.org/core-main/file/0361f0f86dbb/lib.cvsclient/src/org/netbeans/lib/cvsclient/command/BasicCommand.java
 setFiles . . no.
 addRequestsForDirectory(File directory)

In Java there is not a good way of testing for symbolic links :-P
http://stackoverflow.com/questions/813710/java-1-6-determine-symbolic-links

???
http://docs.oracle.com/javase/tutorial/essential/io/fileOps.html
The Files class is "link aware." Every Files method either detects what to do when a symbolic link is encountered, or it provides an option enabling you to configure the behavior when a symbolic link is encountered.
http://docs.oracle.com/javase/tutorial/essential/io/links.html
As mentioned previously, the java.nio.file package, and the Path class in particular, is "link aware." 
Detecting a Symbolic Link

To determine whether a Path instance is a symbolic link, you can use the isSymbolicLink(Path) method. The following code snippet shows how:

Path file = ...;
boolean isSymbolicLink =
    Files.isSymbolicLink(file);
***/

package jco.testsymlink;

import java.io.File;
import java.io.*;
import java.util.*;
//import java.nio.file;

// import org.netbeans.lib.cvsclient.*;

class DirProcess {

    public static boolean isSymlink(File file) throws IOException {
        if (file == null)
             throw new NullPointerException("File must not be null");
        File canon;
        if (file.getParent() == null) {
            canon = file;
        } else {
            File canonDir = file.getParentFile().getCanonicalFile();
            canon = new File(canonDir, file.getName());
        }
        return !canon.getCanonicalFile().equals(canon.getAbsoluteFile());
    }
    
    public static void main(String [ ] args)
    {
	boolean b1;
	try {
	    b1 = isSymlink(new File("ims"));
	    System.err.println("File: ims, is sym link? " + b1);
	}
	catch (IOException ex) {
	    System.err.println("File check error. " + ex);
	    ex.printStackTrace();
	}

	try {
	    b1 = isSymlink(new File("."));
	    System.err.println("File: ., is sym link? " + b1);
	}
	catch (IOException ex) {
	    System.err.println("File check error. " + ex);
	    ex.printStackTrace();
	}

	try {
	    b1 = isSymlink(new File("file.txt"));
	    System.err.println("File: file.txt, is sym link? " + b1);
	}
	catch (IOException ex) {
	    System.err.println("File check error. " + ex);
	    ex.printStackTrace();
	}

	try {
	    b1 = isSymlink(new File("symlink"));
	    System.err.println("File: symlink, is sym link? " + b1);
	}
	catch (IOException ex) {
	    System.err.println("File check error. " + ex);
	    ex.printStackTrace();
	}

    }

}

