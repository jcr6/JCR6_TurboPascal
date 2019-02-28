Unit jcr6;


Interface

  Type TJCR6_Entry = Record
       EntryName:String;
       Size:LongInt; { In DOS LongInt is 32 bit and not 64 like on modern systems! }
       CSize:LongInt;
       Storage:String[20];
  end

  Type TJCR6_DirScan = record
       bt:file;
  end;

  Function StartDirScan(file:String):TJCR6_DirScan;

Implementation

  Function StartDirScan;
  Begin
      { Code comes later }
  End;

End.
