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
    } else {
        testCount = "0"
        testPassed = "0"
        testFailed = "0"
        testSkipped = "0"
        buildDuration = "0"
    }


    def workspace = build.getEnvVars()["WORKSPACE"]
    def buildName = build.getEnvVars()["JOB_NAME"]
    def BUILD_STATUS = build.getEnvVars()["BUILD_STATUS"]
    def BUILD_URL = build.getEnvVars()["BUILD_URL"]
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


test.groovy

</body>
</html>
