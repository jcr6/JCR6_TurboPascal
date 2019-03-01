{ --- START LICENSE BLOCK ---
***********************************************************
testjcr6.pas
This particular file has been released in the public domain
and is therefore free of any restriction. You are allowed
to credit me as the original author, but this is not 
required.
This file was setup/modified in: 
2019
If the law of your country does not support the concept
of a product being released in the public domain, while
the original author is still alive, or if his death was
not longer than 70 years ago, you can deem this file
"(c) Jeroen Broks - licensed under the CC0 License",
with basically comes down to the same lack of
restriction the public domain offers. (YAY!)
*********************************************************** 
Version 19.03.01
  --- END LICENSE BLOCK --- } 
Program TestJCR6;

Uses
  jcr6;
  
var
	jt:tJCRFile;
  
  
Begin
  Writeln('JCR6 test utility');
  JCR_Open(jt,'Test.JCR','Test.txt');
  while not JCR_Eof(jt) do write(JCR_GetChar(jt));
  writeln;
  writeln('All done!');
End.
