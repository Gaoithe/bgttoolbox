<html>
<body>
<%
    if(build.testResultAction) {
        def testResult = build.testResultAction
        def testCount = String.format("%d",(testResult.totalCount))
        def testPassed = String.format("%d",(testResult.result.passCount))
        def testFailed = String.format("%d",(testResult.result.failCount))
        def testSkipped = String.format("%d",(testResult.result.skipCount))
        def buildDuration = String.format("%.2f",(testResult.result.duration ))
    } else {
        def testCount = "0"
        def testPassed = "0"
        def testFailed = "0"
        def testSkipped = "0"
        def buildDuration = "0"
    }

    import hudson.model.*

    def build = Thread.currentThread().executable
    def buildNumber = build.number
    def buildNameJ = build.getDisplayName()

    def workspace = build.getEnvVars()["WORKSPACE"]
    def buildName = build.getEnvVars()["JOB_NAME"]
    def BUILD_STATUS = build.getEnvVars()["BUILD_STATUS"]
    def BUILD_URL = build.getEnvVars()["BUILD_URL"]
    def Test_Server_URL  = build.getEnvVars()["Test_Server_URL"]
    def Group_Name = build.getEnvVars()["Group_Name"]
%>

Summary test report <br><br>

<b><u>Configuration :</u></b><br>
Workspace : $workspace<br>
Project Name : $buildName  $buildNameJ<br>
Test Server URL : $Test_Server_URL<br>
Group Name : $Group_Name<br><br>

<b><u>Execution Results :</u></b><br>
Status : <font color="blue">$BUILD_STATUS</font><br>
Tests run : $testCount<br>
Failures : $testFailed<br>
Errors : . . . TODO . . . <br>
Skipped : $testSkipped<br>
Total time : $buildDuration<br>
Finished at: Tue May 06 17:12:19 IST 2014<br>
Build URL : $BUILD_URL<br><br>

test.groovy

</body>
</html>
