<html>
<body>
<%

    import hudson.model.*

    def build = Thread.currentThread().executable
    def buildNumber = build.number
    def buildNumHash = build.getDisplayName()

    //currentBuildNumber = manager.build.number

    def testCount = "0"
    def testPassed = "0"
    def testFailed = "0"
    def testSkipped = "0"
    def buildDuration = "0"
    if(build.testResultAction) {
        def testResult = build.testResultAction
        testCount = String.format("%d",(testResult.totalCount))
        testPassed = String.format("%d",(testResult.result.passCount))
        testFailed = String.format("%d",(testResult.result.failCount))
        testSkipped = String.format("%d",(testResult.result.skipCount))
        buildDuration = String.format("%.2f",(testResult.result.duration ))
    }

    def workspace = build.getEnvVars()["WORKSPACE"]
    def buildName = build.getEnvVars()["JOB_NAME"]
    def BUILD_STATUS = build.getEnvVars()["BUILD_STATUS"]
    def BUILD_URL = build.getEnvVars()["BUILD_URL"]

    def testResult = hudson.tasks.junit.TestResult

    def testResult2 = build.getAction(hudson.tasks.junit.TestResultAction.class)

%>

Summary test report <br><br>

<b><u>Configuration :</u></b><br>
Workspace : $workspace<br>
Project Name : $buildName $buildNumHash<br>

<b><u>Execution Results :</u></b><br>
Status : <font color="blue">$BUILD_STATUS</font><br>
Tests run : $testCount<br>
Failures : $testFailed<br>
Errors : . . . TODO . . . <br>
Skipped : $testSkipped<br>
Total time : $buildDuration<br>
Finished at: Tue May 06 17:12:19 IST 2014<br>
Build URL : $BUILD_URL<br><br>

<!-- GENERAL INFO -->

<TABLE>
  <TR><TD align="right">
    <j:choose>
      <j:when test="${build.result=='SUCCESS'}">
        <IMG SRC="${rooturl}static/e59dfe28/images/32x32/blue.gif" />
      </j:when>
	  <j:when test="${build.result=='FAILURE'}">
        <IMG SRC="${rooturl}static/e59dfe28/images/32x32/red.gif" />
      </j:when>
      <j:otherwise>
        <IMG SRC="${rooturl}static/e59dfe28/images/32x32/yellow.gif" />
      </j:otherwise>
    </j:choose>
  </TD><TD valign="center"><B style="font-size: 200%;">BUILD ${build.result}</B></TD></TR>
  <TR><TD>Build URL</TD><TD><A href="${rooturl}${build.url}">${rooturl}${build.url}</A></TD></TR>
  <TR><TD>Project:</TD><TD>${project.name}</TD></TR>
  <TR><TD>Date of build:</TD><TD>${it.timestampString}</TD></TR>
  <TR><TD>Build duration:</TD><TD>${build.durationString}</TD></TR>
</TABLE>
<BR/>



<!-- JUnit TEMPLATE  hudson.tasks.junit.TestResult   -->

<br>testResult:${testResult}
<br>testResult2:${testResult2}

<!-- JUnit TEMPLATE -->

<% def junitResultList = it.JUnitTestResult
try {
 def cucumberTestResultAction = it.getAction("org.jenkinsci.plugins.cucumber.jsontestsupport.CucumberTestResultAction")
 junitResultList.add(cucumberTestResultAction.getResult())
} catch(e) {
        //cucumberTestResultAction not exist in this build
}
// API: http://hudson-ci.org/javadoc/hudson/tasks/junit/PackageResult.html

if (junitResultList.size() > 0) { %>
 <TABLE width="100%">
 <TR><TD class="bg1" colspan="2"><B>${junitResultList.first().displayName}</B></TD></TR>
 <% junitResultList.each{
  junitResult -> %>
     <% junitResult.getChildren().each { packageResult -> %>
        <TR><TD class="bg2" colspan="2"> Name: ${packageResult.getName()} Failed: ${packageResult.getFailCount()} test(s), Passed: ${packageResult.getPassCount()} test(s), Skipped: ${packageResult.getSkipCount()} test(s), Total: ${packageResult.getPassCount()+packageResult.getFailCount()+packageResult.getSkipCount()} test(s)</TD></TR>
        <% packageResult.getPassedTests().each{ test -> %>
          <TR bgcolor="lightgreen"><TD class="test" colspan="2"><B><li>PASS: ${test.getFullName()} </li></B></TD></TR>
        <% }
      }
 } %>
 </TABLE>
 <BR/>
<%
} %>

<!-- JUnit TEMPLATE -->

<% def junitResultList2 = it.JUnitTestResult
try {
 def cucumberTestResultAction2 = it.getAction("org.jenkinsci.plugins.cucumber.jsontestsupport.CucumberTestResultAction")
 junitResultList.add(cucumberTestResultAction.getResult())
} catch(e) {
        //cucumberTestResultAction not exist in this build
}
if (junitResultList.size() > 0) { %>
 <TABLE width="100%">
 <TR><TD class="bg1" colspan="2"><B>${junitResultList.first().displayName}</B></TD></TR>
 <% junitResultList.each{
  junitResult -> %>
     <% junitResult.getChildren().each { packageResult -> %>
        <TR><TD class="bg2" colspan="2"> Name: ${packageResult.getName()} Failed: ${packageResult.getFailCount()} test(s), Passed: ${packageResult.getPassCount()} test(s), Skipped: ${packageResult.getSkipCount()} test(s), Total: ${packageResult.getPassCount()+packageResult.getFailCount()+packageResult.getSkipCount()} test(s)</TD></TR>
        <% packageResult.getFailedTests().each{ failed_test -> %>
          <TR bgcolor="#ffcccc"><TD class="test_failed" colspan="2"><B><li>FAIL: ${failed_test.getFullName()} </li></B></TD></TR>
        <% }
      }
 } %>
 </TABLE>
 <BR/>
<%
} %>

<!-- JUnit TEMPLATE: all tests PASS FAIL SKIP >
<% 
if (junitResultList.size() > 0) { %>
 <TABLE width="100%">
 <TR><TD class="bg1" colspan="2"><B>${junitResultList.first().displayName}</B></TD></TR>
 <% junitResultList.each{
  junitResult -> %>
     <% junitResult.getChildren().each { packageResult -> %>
        <TR><TD class="bg2" colspan="2"> Name: ${packageResult.getName()} Failed: ${packageResult.getFailCount()} test(s), Passed: ${packageResult.getPassCount()} test(s), Skipped: ${packageResult.getSkipCount()} test(s), Total: ${packageResult.getPassCount()+packageResult.getFailCount()+packageResult.getSkipCount()} test(s)</TD></TR>
        <% packageResult.getChildren().each{ suite -> 
               suite.getChildren().each{ test ->
           def colour = "lightgreen"
           def highlight1=""
           def highlight2=""
           RESULT = test.getStatus() // FAILED or PASSED or SKIPPED
           if (RESULT == hudson.tasks.junit.CaseResult.Status.FAILED || RESULT == hudson.tasks.junit.CaseResult.Status.REGRESSION) {
               colour = "#ffcccc" 
               highlight1="<B>"
               highlight2="</B>"
           }
           if (RESULT == hudson.tasks.junit.CaseResult.Status.SKIPPED) { colour = "#ffffb3" }
         %>
          <TR bgcolor="${colour}"><TD class="test" colspan="2">${highlight1}<li>${RESULT}: ${test.getFullName()} </li>${highlight2}</TD></TR>
        <% } }
      }
 } %>
 </TABLE>
 <BR/>
<%
} %>



test.groovy

</body>
</html>
