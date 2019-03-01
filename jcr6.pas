{ --- START LICENSE BLOCK ---
  jcr6.pas
  JCR6 for Turbo Pascal
  version: 19.03.01
  Copyright (C) 2019 Jeroen P. Broks
  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
  --- END LICENSE BLOCK --- } 
Unit jcr6;

{$UNDEF DEBUGCHAT}


interface

	uses 
		TReadStr,
		Conv;
		
	type tJCREntry = record
		name:string;
		storage:string; { Non 'Store' items cannot be read, but if 
		                  if not called they should crash stuff }
		size:Longint;
		offset:Longint;
		jxsrcca:Boolean
	end;
	
	type tJCRFile = record
		stream:file;
		size,offset:longint;		
		cbyte,lbyte,pbyte:byte;
		packpos:LongInt;
		jxsrcca:boolean;
		gbyte:boolean;
	end;
	
	var
		showcomments:boolean;
	
	procedure JCR_OpenDir(var ret:file;filename:string);
	procedure JCR_Next(var ret:file; var success:boolean; var entry:tJCREntry);
	procedure JCR_CloseDir(var ret:file);
	procedure JCR_Open(var ret:tJCRfile;resource,entry:string);
	
	function  JCR_Eof(var ret:tJCRfile):boolean;
	function  JCR_GetChar(var ret:tJCRfile):char;
	function  JCR_GetByte(var ret:tJCRfile):byte;
	function  JCR_GetInteger(var ret:tJCRfile):integer;
	function  JCR_GetLongInt(var ret:tJCRfile):LongInt;
	function  JCR_GetPascalString(var ret:tJCRfile):string;


implementation

	procedure dbg(a:string);
	begin
		{$IFDEF DEBUGCHAT}
		writeln('Debug>':10,' ',a)
		{$ENDIF}
	end;

	procedure J_CRASH(error:string);
	begin
		WriteLn('JCR Error');
		WriteLn(error);
		halt(1);
	end;

	procedure JCR_OpenDir;
	var
		ecatch:integer;
		header:array[0..5] of Char;
		fatoffset:longint;
		fat_size,fat_csize:longint;
		fat_storage:string;
	begin
		{ Open the file and throw and error if it doesn't exist}
		assign(ret,filename);
		{$I-}
		reset(ret,1);
		{$I+}
		ECatch:=IOResult;
		if ECatch=2 then J_Crash('File not found: '+filename);
		if ECatch>0 then J_Crash('Error opening file');
		
		{ Is this an actual JCR6 file? }
		blockread(ret,header,5); 
		if not( (header[0]='J') and (header[1]='C') and (header[2]='R') and (header[3]='6') and (header[4]=#26) ) then begin
			close(ret);
			J_Crash(filename+': has not be recognized as a JCR6 resource file')
		end;
		
		{ Let's get the FAT offset }
		blockread(ret,fatoffset,sizeof(fatoffset));
		if fatoffset<=0 then begin
			close(ret);
			J_CRASH('Invalid offset')
		end;
		
		{ Now there is room for some extra config but this simplistic version of JCR6 will ignore all 
		  that crap and go straight into business }
		seek(ret,fatoffset);
		
		blockread(ret,fat_size ,sizeof(longint));
		blockread(ret,fat_csize,sizeof(longint));
		TrickyReadString(ret,fat_storage);
		if fat_storage<>'Store' then begin
			close(ret);
			J_Crash('Resource is packed with the ' +
						fat_storage+
						' algorithm, and this JCR6 unit only supports non-compressed resources')
		end;
		if fat_size<>fat_csize then begin
			close(ret);
			J_Crash('Invalid FAT size data');
		end;
		
		{ From here we can begin to work, so this procedure comes at an end }
	end;

	procedure JCR_Next;
	var
		SuperMaintag:byte;
		CommandTag:string;
		Needless:string; (* Used to skip unsupported stuff *)
		NeedlessByte:Byte;
		EntryTag:Byte;
		EntryField:string;
		Entryint:longint;
		entrystring:string;
		entrybyte:byte; { used for boolean readouts which this unit will ignore }
	begin
		repeat
			blockread(ret,SuperMainTag,1);
			Case SuperMainTag of
				$ff:
					begin
						success:=false;
						Exit
					end;
				$01:
					begin
						TrickyReadString(ret,Commandtag);
						if CommandTag='COMMENT' then begin
							TrickyReadString(ret,Needless); if showcomments then writeln('Comment: '+Needless);
							TrickyReadString(ret,Needless); if showcomments then writeln(Needless)
						end
						else if CommandTag='REQUIRE' then begin
							close(ret);
							J_Crash('REQUIRE statement in JCR6. That feature is NOT supported')
						end
						else if CommandTag='IMPORT' then begin
							{ Not supported, but this can be ingored }
							BlockRead(ret,needlessbyte,1);
							TrickyReadString(ret,needless);
							TrickyReadString(ret,needless)
						end
						else if commandTag='FILE' then repeat
							success:=true;
							blockread(ret,entrytag,1);							
							case entrytag of
								$01,$02,$03:
									begin
										trickyreadstring(ret,EntryField);
										dbg('Field='+Entryfield+' ('+jbstr(entrytag)+')');
										with entry do
										begin
											case entrytag of
												1:	begin
														trickyreadstring(ret,entrystring);
														if EntryField='__Entry' then name:=entrystring;
														if EntryField='__Storage' then storage:=entrystring
													end;
												2:	begin
														blockread(ret,entrybyte,1)
													end;
												3:	begin
														blockread(ret,entryint,sizeof(longint));
														if EntryField='__Size' then size:=entryint;
														if EntryField='__Offset' then offset:=entryint;
													end;
											end;
										end;
									end;	
							$ff:	begin	end {crash prevention}
							else begin
									close(ret);
									J_Crash('Entry tagging error');
								end;
							end;
						until entrytag=$ff
						else begin
							close(ret);
							J_Crash('I don''t know what to do with command tag: '+commandtag)
						end
					end
				else
					begin
						close(ret);
						J_Crash('Unknown tag: '+jbstr(supermaintag))
					end;
			end
		until success;
	end;

	procedure JCR_closedir;
	begin
		close(ret);
	end;
	
	
	procedure JCR_Open;
	var
		e:tJCREntry;
		s:Boolean;
		ignore:byte;
	begin
		with ret do begin
			packpos:=0;
			{assign(stream,resource);
			reset(stream,1);}
			JCR_OpenDir(stream,resource);
			repeat
				JCR_Next(stream,s,e);
				if not s then begin
					close(stream);
					J_Crash('Entry '+entry+' not found in '+resource)
				end;
				if jupper(e.name)=jupper(entry) then begin
					size   := e.size;
					offset := e.offset;
					seek(stream,offset);
					e.jxsrcca := (e.storage='jxsrcca');
					jxsrcca:=e.jxsrcca;
					if (e.storage<>'jxsrcca') and (e.storage<>'Store') then begin
						close(stream);
						J_Crash('Storage method '+e.storage+' not supported for entry '+entry+' in '+resource)
					end;
					exit
				end
			until false;
			if e.jxsrcca then blockread(stream,ignore,1) { First byte is always added by Go, but it's useless }
		end
	end;
	
	function JCR_Eof;
	var
		p:longint;
	begin
		with ret do begin
			if jxsrcca then
				JCR_Eof:=packpos+1>=size {Very important no ; !!! Pascal forbids a ; when 'else' commes immediately after}
			else begin
				p:=filepos(stream);
				JCR_Eof:=p>=offset+size
			end
		end
	end;

	function JCR_GetByte;
	var c:Byte;
	begin
		with ret do begin
			if jxsrcca then begin
				if (not gbyte) or (pbyte>=lbyte) then begin
					{$IFDEF DEBUGCHAT}
					Writeln('Position: ',packpos,' NEW');
					{$ENDIF}
					if not gbyte then blockread(stream,c,1); {nul-ignore}
					gbyte:=true;
					pbyte:=1;
					blockread(stream,cbyte,1);
					blockread(stream,lbyte,1);
					{$IFDEF DEBUGCHAT}
					Writeln('- cbyte: ',cbyte,'; lbyte: ',lbyte);
					Readln;
					{$ENDIF}
					JCR_GetByte:=cbyte
				end else begin
					inc(pbyte);
					JCR_GetByte:=cbyte
				end;
				inc(packpos)
			end else begin
				blockread(stream,c,1);
				JCR_GetByte:=c;
			end
		end {width}
	end;
	
	function JCR_GetChar;
	var c:char;
	begin
		c := chr(JCR_GetByte(ret));
		{blockread(ret.stream,c,1);}
		JCR_GetChar:=c
	end;


	function JCR_GetInteger;
	var c:Integer;
		ia:array[0..2] of byte;
		i:integer absolute ia;
	begin
		if ret.jxsrcca then begin
			ia[0]:=JCR_GetByte(ret);
			ia[1]:=JCR_GetByte(ret);
			JCR_GetInteger:=i;
		end else begin
			blockread(ret.stream,c,2); {sizeof(c));}
			JCR_GetInteger:=c
		end
	end;

	function JCR_GetLongInt;
	var c:LongInt;	
		ia:array[0..4] of byte;
		i:LongInt absolute ia;
		k:byte;
	begin
		if ret.jxsrcca then begin
			for k:=0 to 3 do ia[k]:=JCR_GetByte(ret);
			JCR_GetLongInt:=i;
		end else begin
			blockread(ret.stream,c,2); {sizeof(c));}
			JCR_GetLongInt:=c
		end
	end;

	function JCR_GetPascalString;
	var c:string;
		i:integer;
		a:array[0..255] of byte;
		s:string absolute a;
	begin
		if ret.jxsrcca then begin 
			for i:=0 to 255 do a[i]:=JCR_GetByte(ret);
			JCR_GetPascalString:=s
		end else begin
			blockread(ret.stream,c,sizeof(c));
			JCR_GetPascalString:=c
		end
	end;

begin
	showcomments:=false;
end.

