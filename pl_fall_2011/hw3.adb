with Ada.Text_IO, Ada.Command_line, Ada.Assertions; 
use Ada.Text_IO, Ada.Assertions; 
with Polynomials; 
use Polynomials; 

-- Test file format:
-- # comments start with hash character 
-- 1.0 X 1 Y 2 2.0 X 2 Y 0
-- + 
-- 1.0 X 1 Y 2
-- 2.0 X 1 Y 2 2.0 X2 Y 0 

procedure hw3 is
    package CL renames Ada.Command_line; 
    
    File : File_Type;
    
    -- first input polynomial 
    P1 : Polynomial := Null_Polynomial; 
    -- second input polynomial 
    P2 : Polynomial := Null_Polynomial; 
    -- operation to perform between polynomials
    Operator : String := "+";
    -- used when reading line into string
    Last : Natural; 
    -- expected result 
    Expected : Polynomial := Null_Polynomial; 
    -- actual result 
    Result : Polynomial;
    -- used to peek for comment characters 
    C : Character; 
    EOL : Boolean; 
begin 
    -- make sure the filename has been given as a commandline arg
    Assert(CL.Argument_Count /= 0, "file name not given"); 
    -- also assert that no additional args were given
    Assert(CL.Argument_Count < 2, "too many arguments"); 
    Open (File => File, Mode => In_File, Name => CL.Argument(1));
    loop
        -- stop if we're at the end of the file 
        if End_Of_File(File => File) then exit; end if; 
        -- skip comment lines 
        loop 
            Look_Ahead (File => File, Item => C, End_Of_Line => EOL); 
            if C /= '#' then exit; 
            else Skip_Line(File); 
            end if; 
        end loop; 
        -- after all comments we may again be at the end of the file 
        if End_Of_File(File => File) then exit; end if; 
        
        -- read first polynomial input 
        P1 := Read(File); 
        Write(P1); 
        
        Get_Line(File => File, Item => Operator, Last => Last); 
        -- make sure second line is a valid operator
        Assert(Operator = "+" or Operator = "*", "Malformed operator"); 
        Put_Line(Operator); 
        
        -- read second polynomial input 
        P2 := Read(File);
        Write(P2); 
        
        if Operator = "+" then 
            Result := P1 + P2; 
        else 
            Result := P1 * P2; 
        end if; 
        
        Put_Line("="); 
        Write(Result); 
        Expected := Read(File); 
        if not (Result = Expected) then 
            Put("ERROR: Expected result = "); 
            Write(Expected); 
        else 
            Put_Line("OK");
        end if; 
        Put_Line("---"); 
    end loop; 
    Close (File => File); 
end hw3; 
