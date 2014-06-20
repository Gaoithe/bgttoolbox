/*
+----------------------------------------------------------------------+
|                    Class: CLauncher                                  |
|                                                                      |
| Developer:   Eric Gavaldo (egavaldo@xqual.com)                       |
|              Jumbo                                                   |
|              James Coleman (jamesc@dspsrv.com)                       |
|                                                                      |
+----------------------------------------------------------------------+
*/

/*
 This file was created by changing the perl CLauncherImpl.java        
  s/perl/tcl/gi; s/\.pl/\.tcl/g;
 It has been tested with ActiveTcl, tcl interpreter: C:/Tcl/bin/tclsh85.exe

 It implements the same test interface as XStudio perl (and other).
 Test generates log.txt with lines including [Success] or [Failure]
 or [Log]. Test is deemed complete when a file test_completed.txt is created.
*/

package com.xqual.xlauncher.tcl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.Vector;

import com.xqual.xagent.launcher.CExecutionStep;
import com.xqual.xagent.launcher.CLauncher;
import com.xqual.xagent.launcher.CParamParsingException;
import com.xqual.xagent.launcher.CReturnStatus;
import com.xqual.xagent.launcher.runner.CRunner;
import com.xqual.xagent.launcher.runner.IRunner;
import com.xqual.xcommon.CAttribute;
import com.xqual.xcommon.IConstantsResults;
import com.xqual.xlauncher.CTimeoutListener;

/**
 * The <code>CLauncherImpl</code> implementation of <code>ILauncher</code> for Tcl.
 * @author egavaldo & jumbo & jamesc
 */
public class CLauncherImpl extends CLauncher implements IConstantsResults {

	// +==============================================================+
	// | Attributes                                                   |
	// +==============================================================+

	static final String TRACE_HEADER = "{tcl          }  ";

	// parameters impacting executing at run time set by the test operator
	private String testRootPath;
	private int timeout = 600;
	private String tclInstallPath;
	private File tclInterpreter;
	
	private File workingDir;
	
	private static final String TCL_INTERPRETER_EXE = "tclsh85.exe";

	// +==============================================================+
	// | Constructors                                                 |
	// +==============================================================+

	public CLauncherImpl() {
		super(TRACE_HEADER);
	}

	// +==============================================================+
	// | Methods                                                      |
	// +==============================================================+

	public CReturnStatus initialize(int sutId, String sutName, String sutVersion) {
		setSutDetails(sutId, sutName, sutVersion);
		
		// check the configuration sent by the manager
		printConfiguration();

		Vector<CExecutionStep> executionSteps = new Vector<CExecutionStep>();
		try {
			// retrieve the parameters we need
			testRootPath    = getStringParamValue("General",  "Test root path");
			timeout         = getIntegerParamValue("General", "Asynchronous timeout (in seconds)");
			
			tclInstallPath = getStringParamValue("Tcl",     "Tcl install path");
			tclInterpreter = new File(tclInstallPath + "\\" + TCL_INTERPRETER_EXE);
		} catch (CParamParsingException e) {
			traceln(LOG_PRIORITY_SEVERE, "parsing error during initialization");
			executionSteps.add(new CExecutionStep(RESULT_FAILURE, "Exception during initialize: " + e.getMessage()));
			return new CReturnStatus(RESULT_FAILURE, executionSteps);
		}
		return new CReturnStatus(RESULT_SUCCESS, executionSteps);
	}

	public CReturnStatus preRun(int testId, String testPath, String testName, Vector<CAttribute> attributes) {
		traceln(LOG_PRIORITY_INFO, "preRun testId=" + testId + " testPath=" + testPath + ":" + testName + "...");
		Vector<CExecutionStep> executionSteps = new Vector<CExecutionStep>();
		return new CReturnStatus(RESULT_SUCCESS, executionSteps);	
	}
	
	public CReturnStatus run(int testId, String testPath, String testName, int testcaseIndex) {
		traceln(LOG_PRIORITY_INFO, "run testId=" + testId + " testPath=" + testRootPath + "/" + testPath + "/" + testName + " testcaseIndex=" + testcaseIndex + "...");
		Vector<CExecutionStep> executionSteps = new Vector<CExecutionStep>();

		String scriptParentFolderPath = testRootPath + "/" + testPath + "/";
		workingDir = new File(scriptParentFolderPath);
	
		// +------------------------------------+
		// | Interpret the script
		// +------------------------------------+
		CRunner tclRunner = new CRunner("[" + testId + "] "+ testPath + ":" + testName + "." + testcaseIndex,
                                           tclInterpreter.toString() + " " + testRootPath + "/" + testPath + "/" + testName + ".tcl " +
                                           "/debug " +
                                           "/testcaseIndex=" + testcaseIndex,
                                           workingDir);
		short result = tclRunner.requestAction(IRunner.START_PROCESS, IRunner.DO_NOT_WAIT_END_OF_EXECUTION);
		if (result == RESULT_FAILURE) {
			executionSteps.add(new CExecutionStep(RESULT_FAILURE, "script interpretation failed"));
			return new CReturnStatus(RESULT_FAILURE, executionSteps);
		}
		
		// to check if the execution completed correctly, we need to check if the "test_completed.txt" has been created
		short resultTimeout = CTimeoutListener.waitForFile(new File(workingDir + "/test_completed.txt"), timeout);
		if (resultTimeout != RESULT_SUCCESS) {
			executionSteps.add(new CExecutionStep(RESULT_SUCCESS, "timeout of " + timeout + " seconds to execute the test case expired"));
			return new CReturnStatus(RESULT_FAILURE, executionSteps);
		}
		
		return parseResultFile(executionSteps);
	}
	
	public CReturnStatus postRun(int testId, String testPath, String testName) {
		traceln(LOG_PRIORITY_INFO, "postRun testId=" + testId + " testPath=" + testPath + ":" + testName + "...");
		Vector<CExecutionStep> executionSteps = new Vector<CExecutionStep>();
		executionSteps.add(new CExecutionStep(RESULT_SUCCESS, "postRun: succeeded"));
		return new CReturnStatus(RESULT_SUCCESS, null);
	}
	
	public CReturnStatus terminate() {
		Vector<CExecutionStep> executionSteps = new Vector<CExecutionStep>();
		executionSteps.add(new CExecutionStep(RESULT_SUCCESS, "Terminate"));
		return new CReturnStatus(RESULT_SUCCESS, executionSteps);
	}
	
	// +--------------------------+
	// ¦        Utilities         ¦
	// +--------------------------+
	
	private CReturnStatus parseResultFile(Vector<CExecutionStep> executionSteps) {
		// parse the result file to get the result and the execution steps
		File resultFile = new File(workingDir + "/log.txt");
		if (!resultFile.exists()) {
			traceln(LOG_PRIORITY_SEVERE, "Result file not found!");
			executionSteps.add(new CExecutionStep(RESULT_FAILURE, "run: result file not found!"));
			return new CReturnStatus(RESULT_FAILURE, executionSteps);
		} else {
			executionSteps.add(new CExecutionStep(RESULT_SUCCESS, "run: result file found"));
		}

		String line, message;
		boolean errorDetected = false;

		try {
			FileInputStream fileInputStream = new FileInputStream(resultFile);
			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(fileInputStream));

			while ((line = bufferedReader.readLine()) != null) {
				line = line.trim();
				System.out.println(">" + line);
				if (line.indexOf("[Success]")>=0) {
					message = line.substring(10, line.length()); // [Success] length = 9
					executionSteps.add(new CExecutionStep(RESULT_SUCCESS, message));

				} else if (line.indexOf("[Failure]")>=0) {
					message = line.substring(10, line.length());
					executionSteps.add(new CExecutionStep(RESULT_FAILURE, message));
					errorDetected = true;

				} else if (line.indexOf("[Log]")>=0) {
					message = line.substring(6, line.length());
					executionSteps.add(new CExecutionStep(RESULT_UNKNOWN, message));

				} else {
					//traceln(LOG_PRIORITY_SEVERE, "unknown tag!");
				}
			}

		} catch (Exception e) {
			traceln(LOG_PRIORITY_SEVERE, "exception whle parsing the result file: " + e);
			executionSteps.add(new CExecutionStep(RESULT_FAILURE, "Exception whle parsing the result file: " + e));
			errorDetected = true;
		}
		
		if (errorDetected) {
			return new CReturnStatus(RESULT_FAILURE, executionSteps);
		} else {
			return new CReturnStatus(RESULT_SUCCESS, executionSteps);
		}
	}
}
