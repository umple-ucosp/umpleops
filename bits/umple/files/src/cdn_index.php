<?php
function endsWith($haystack, $needle) {
  return $needle === "" ||
         (($temp = strlen($haystack) - strlen($needle)) >= 0 &&
          strpos($haystack, $needle, $temp) !== FALSE);
}

function invalidFile($file)
{
  return endsWith($file, ".php") ||
         endsWith($file, ".out") ||
         endsWith($file, ".swp") ||
         $file == "." ||
         $file == "..";
}

function findFiles($dir, $prefix)
{
  if (!file_exists($dir)) { return []; }
  $answer = [];

  foreach(scandir($dir, SCANDIR_SORT_DESCENDING) as $file)
  {
    if (invalidFile($file))
    {
      continue;
    }

    $fullPath = "{$prefix}/{$file}";
    if (is_dir($fullPath))
    {
      $answer += findfiles($fullPath, $fullPath);
    }
    else
    {
      $answer[] = $fullPath;
    }
  }
  return $answer;
}

$baseUrl = "http://" . $_SERVER["HTTP_HOST"];
$latest = findFiles("./latest", "latest");
$numLatest = count($latest);

$inTests = findFiles("./tests", "tests");
$numInTests = count($inTests);

$releases = findFiles("./releases", "releases");
$numReleases = count($releases);

?>
<html>
  <head>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <title>Umple Releases</title>
  </head>

  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-6">
          <h2>Latest Build (<?php echo $numLatest ?>)</h2>
          <p>
            Our latest builds refer to the last time umple code was
            committed, and all of our automated QA verification steps
            succeeded.
          </p>
          <p>
            This version will be identical to that on <a href="http://try.umple.org">try.umple.org</a>
          </p>
          <div class="list-group">
          <?php
          if ($numLatest > 0) {
            foreach($latest as $file)
            {
              echo "<a href=\"/{$file}\" class=\"list-group-item\">{$baseUrl}/{$file}</a>";
            }
          } else {
            echo "<p>No latest builds available.</p>";
          }
          ?>
          </div>
        </div>
        <div class="col-md-6">
          <h2>Interim QA Release (<?php echo $numInTests ?>)</h2>
          <p>
            During our testing, we make available interim JARs so that dependent
            compoents can run their tests against the latest unverified versions
            of our libaries.
          </p>
          <p>
            If all goes well, then these releases get promoted to be our latest,
            otherwise they are removed.  If there are problems, then then the
            files are removed and our build server will report a failure.
          </p>
          <p>
            PLEASE DO NOT EXPECT THESE LINKS TO ALWAYS BE AVAILABLE.
          </p>
          <div class="list-group">
          <?php
          if ($numInTests > 0) {
            foreach($inTests as $file)
            {
              echo "<a href=\"/{$file}\" class=\"list-group-item\">{$baseUrl}/{$file}</a>";
            }
          } else {
            echo "<p>No testing going on, so none available.</p>";
          }
          ?>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-md-6">
          <h2>All Releases (<?php echo $numReleases ?>)</h2>
          <p>
            Our releases represent milestones of accomplishment and are usually
            done each season.  We use Major.Minor.Release-Patch numbering,
            where Patch used to represent the SVN revision number, and going forward
            not sure if we will the git hash or not.
          </p>
          <div class="list-group">
          <?php
          if ($numReleases > 0) {
            foreach($releases as $file)
            {
              echo "<a href=\"/{$file}\" class=\"list-group-item\">{$baseUrl}/{$file}</a>";
            }
          } else {
            echo "<p>No releases available.</p>";
          }
          ?>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>