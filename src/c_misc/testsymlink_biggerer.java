
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
***/

//package jco.testsymlink;

import java.io.*;
import java.util.*;

// import org.netbeans.lib.cvsclient.*;

public class testsymlink_biggerer {

    boolean recursive = true;
    public boolean isRecursive() {
        return recursive;
    }

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
    
    /**
     * Add the appropriate requests for a specified path. For a directory,
     * process all the files within that directory and for a single file,
     * just send it. For each directory, send a directory request. For each
     * file send an Entry request followed by a Modified request.
     * @param path the particular path to issue requests for. May be
     * either a file or a directory.
     */
    private void addRequests(File path)
	throws FileNotFoundException, IOException, CommandAbortedException {
	if (path == null) {
	    throw new IllegalArgumentException("Cannot add requests for a " +
					    "null path.");
	}
	
	if (!path.exists() || path.isFile()) {
	    addRequestsForFile(path);
	}
	else {
	    addRequestsForDirectory(path);
	}
    }

    public void addRequestsForDirectory(File directory)
           throws IOException {
        //addDirectoryRequest(directory);
        File [] dirFiles = directory.listFiles();
        List localFiles;
        if (dirFiles == null) {
             localFiles = new ArrayList(0);
        } else {
             localFiles = new ArrayList(Arrays.asList(dirFiles));
             localFiles.remove(new File(directory, "CVS"));
        }
    
        List subDirectories = null;
        if (isRecursive()) {
             subDirectories = new LinkedList();
        }
    
        // get all the entries we know about, and process them
        //for (Iterator it = clientServices.getEntries(directory); it.hasNext();) {
        //    final Entry entry = (Entry)it.next();
        //    final File file = new File(directory, entry.getName());
        //    if (entry.isDirectory()) {
        //        if (isRecursive()) {
        //            subDirectories.add(new File(directory, entry.getName()));
        //        }
        //    }
        //    else {
        //        addRequestForFile(file, entry);
	//   }
        //    localFiles.remove(file);
        //}
        
        // In case that CVS folder does not exist, we need to process all
        // directories that have CVS subfolders:
        if (isRecursive() && !new File(directory, "CVS").exists()) {
            File[] subFiles = directory.listFiles();
            if (subFiles != null) {
                for (int i = 0; i < subFiles.length; i++) {
                    if (subFiles[i].isDirectory() && new File(subFiles[i], "CVS").exists()) {
                        subDirectories.add(subFiles[i]);
                    }
                }
            }
        }
    
        //for (Iterator it = localFiles.iterator(); it.hasNext();) {
        //    String localFileName = ((File)it.next()).getName();
        //    if (!clientServices.shouldBeIgnored(directory, localFileName)) {
        //        addRequest(new QuestionableRequest(localFileName));
        //    }
        //}
    
        if (isRecursive()) {
            for (Iterator it = subDirectories.iterator(); it.hasNext();) {
                File subdirectory = (File)it.next();
                File cvsSubDir = new File(subdirectory, "CVS"); //NOI18N
                //if (clientServices.exists(cvsSubDir)) {
                //    addRequestsForDirectory(subdirectory);
                //}
            }
        }
    }
    
    /**
     * This method is called for each explicit file and for files within a
     * directory.
     */
    //protected void addRequestForFile(File file, Entry entry) {
    //    sendEntryAndModifiedRequests(entry, file);
    //}
    
    /**
     * Add the appropriate requests for a single file. A directory request
     * is sent, followed by an Entry and Modified request
     * @param file the file to send requests for
     * @throws IOException if an error occurs constructing the requests
     */
    protected void addRequestsForFile(File file) throws IOException {
        addDirectoryRequest(file.getParentFile());
	
	try {
	    File entry = null;
	    //final Entry entry = clientServices.getEntry(file);
	    // a non-null entry means the file does exist in the
	    // Entries file for this directory
	    if (entry != null) {
		addRequestForFile(file, entry);
	    } else if (file.exists()) {
		// #50963 file exists locally without an entry AND the request is
		// for the file explicitly
		boolean unusedBinaryFlag = false;
		addRequest(new ModifiedRequest(file, unusedBinaryFlag));
	    }
	}
	catch (IOException ex) {
	    System.err.println("An error occurred getting the Entry " +
			    "for file " + file + ": " + ex);
	    ex.printStackTrace();
	}
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

        testsymlink_biggerer dp = new testsymlink_biggerer("ims");
	dp.addRequests(new File("ims"));
    }

}

