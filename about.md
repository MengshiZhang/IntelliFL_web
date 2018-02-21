---
title: IntelliFL | About
id: about
permalink: /about/
layout: about
---

### IntelliFL is a lightweight tool for automated debugging. ###
Given any Java project with failing JUnit tests, IntelliFL will perform both static and dynamic analyses to automatically localize the potential buggy method(s). The final output of IntelliFL is a ranked list of suspicious program methods in the decending order of their probability to be buggy. The users can then inspect the list from the beginning to identify the real buggy method(s).

## Requirements ##

- JDK 7/8/9
- Maven 3+
- JUnit 3/4 (JUnit4.6+ library required even for JUnit3 tests)
- Python 2/3 with Pandas and Numpy


## IntelliFL Installation ##

Clone IntelliFL :
```
$ git clone https://bitbucket.org/zhanglm10/intellifl
```
 
Install IntelliFL:
```
$ cd intellifl | mvn clean install
```

## Using IntelliFL (Maven Plugin) ##

Include the following plugin in the maven project under test:
```
<project>
  ...
  <build>
    ...
    <plugins>
      ...
       <plugin>
         <groupId>org.intelliFL</groupId>
         <artifactId>intelliFL-maven-plugin</artifactId>
         <version>1.0-SNAPSHOT</version>
       </plugin>
      ...
    </plugins>
      ...
  </build>
    ...
</project>
```


**Step-1: Dynamic Analysis** Collect method coverage:
  
```
$ mvn intelliFL:meth-cov
```

**Step-2: Static Analysis** Collect call graph:
  
```
$ mvn intelliFL:cg
```

**Step-3: Fault Localization** Perform PRFL fault localization:
  
```
$ mvn intelliFL:prfl
```

**All-in-One Analysis** A single command including all the above steps:
    
```
$ mvn intelliFL:prfl-comb
```


IntelliFL can also be directly applied for any Maven project **without** modifying pom.xml. 
Simply replace "intelliFL" of above commands with IntelliFL groupID, artifactID and version information, e.g.,: 

```
$ mvn org.intelliFL:intelliFL-maven-plugin:1.0-SNAPSHOT:prfl-comb
```

**Note** From Java 9, JDK disallows attaching to the current VM by
 default, and requires "jdk.attach.allowAttachSelf" argument to be
 TRUE for attaching to VM. Therefore, the Maven JVM configuration
 must be set to "-Djdk.attach.allowAttachSelf=true" for IntelliFL
 Maven plugin to interact with JVM:
 
 * Linux/Mac: `export MAVEN_OPTS=-Djdk.attach.allowAttachSelf=true"`
 * Windows: `set MAVEN_OPTS=-Djdk.attach.allowAttachSelf=true"`
 * Or: Starting the Maven 3.3.1 release, Maven JVM configurations can also be set via `${maven.projectBasedir}/.mvn/jvm.config`, e.g., with line `-Djdk.attach.allowAttachSelf=true`.

## Using IntelliFL (Command Line Supports) ##

Besides Maven plugin, IntelliFL also supports command line usage for project with any build system (e.g., IDE, Ant, Maven, and Gradle).

**Step-1: Dynamic Analysis** To collect method coverage, set the following Java Agent configuration for test execution, which supports any 
build system:
    
```
-javaagent:/absolute/path/to/intelliFL-core-${version}.jar=covLevel=meth-cov,baseDir=/absolute/path/to/subject,clsDir=/absolute/path/to/subject/bytecode/directory
```

For Maven, one example to collect method coverage is as follows:

```
$ mvn test -DargLine= -javaagent:~/.m2/repository/org/intelliFL/intelliFL-core/1.0-SNAPSHOT/intelliFL-core-1.0-SNAPSHOT.jar=covLevel=meth-cov,baseDir=~/CommansLang,clsDir=~/CommansLang/target/classes
```

Also, "argLine" can be integrated into pom.xml:
```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
      <configuration>
        <argLine>-javaagent:/absolute/path/to/intelliFL-core-${version}.jar=${configs}</argLine>
      </configuration>
</plugin>
```

For Ant, the following setting can be integrated into build.xml:
```
<junit ...>
  <jvmarg value="-javaagent:/absolute/path/to/intelliFL-core-${version}.jar=${configs}" />
</junit>
```

Furthermore, method coverage can be collected directly by running "java" command:

```
$ java -cp ${project-classpath} -javaagent:/absolute/path/to/intelliFL-core-${version}.jar=${configs} org.junit.runner.JUnitCore ${test-class}
```

**Step-2: Static Analysis** Collect call graph:

```
$ java -cp /absolute/path/to/intelliFL-core-${version}.jar set.intelliFL.cg.CallGraphBuilder /absolute/path/to/subject/bytecode/directory
```

One example to collect call graph is:

```
$ java -cp ~/.m2/repository/org/intelliFL/intelliFL-core/1.0-SNAPSHOT/intelliFL-core-1.0-SNAPSHOT.jar set.intelliFL.cg.CallGraphBuilder ~/CommansLang/target/classes/
```

**Step-3: Fault Localization** Perform PRFL fault localization:

```
$ java -cp /absolute/path/to/intelliFL-core-${version}.jar set.intelliFL.techs.PRFL
```

One example to perform PRFL fault localization is:

```
$ java -cp ~/.m2/repository/org/intelliFL/intelliFL-core/1.0-SNAPSHOT/intelliFL-core-1.0-SNAPSHOT.jar set.intelliFL.techs.PRFL
```

**Note** All steps are required to run in the root directory of the subject under test.

## IntelliFL Outputs ##

**Dynamic Analysis Output** Method coverage information is in the directory:
`/absolute/path/to/subject/intelliFL/intelliFL-meth-cov` 

**Static Analysis Output** Call graph information is in the directory: 
`/absolute/path/to/subject/intelliFL/intelliFL-cg`

**Fault Localization Output** The final fault localization result file(.csv) with all the ranked suspicious methods is in 
`/absolute/path/to/subject/intelliFL/intelliFL-output/pr_ranking`


One example of final output is as follows:


```org/joda/time/field/UnsupportedDurationField:compareTo(Lorg/joda/time/DurationField;)I,0.250891463466```

It shows that the suspicousness value of method "compareTo" in the 
class "org.joda.time.field.UnsupportedDurationField" is 0.250891463466


## Optional Configurations ##

| Configuration | Description | Default | 
|---|---|---|---|---|
| -DspecTech=...  | The used intelliFL formula |  PR_Ochiai      |  
| -Daggregation=... |Whether to do aggressive aggregation-based PRFL |false  | 
| -DskipIT=...  |Whether to skip integration tests (**Maven only**) |  false |   

**Note**

* Currently, intelliFL supports following settings of spectrum-based fault localization:
    + PR_Ochiai(Default)
    + PR_Tarantula
    + PR_SBI
    + PR_Jaccard
    + PR_Ochiai2
    + PR_Kulczynski
    + PR_Dstar2
    + PR_Op2

* To perform aggregation-based PRFL, statement coverage must be collected instead of method coverage:`mvn intelliFL:stmt-cov`. Usually aggregation-based PRFL provides more effective but slightly more costly fault localization

* The "skipIT" configuration only works for collecting coverage during Maven integration test scenario, while "specTech" and "aggregation" work for performing fault localization using both the Maven plugin and cmd support
