with Ada.Assertions; 
use Ada.Assertions; 
with Ada.Unchecked_Deallocation;
with Ada.Integer_Text_IO, Ada.Float_Text_IO,  Ada.Text_IO; 
use Ada.Integer_Text_IO, Ada.Float_Text_IO, Ada.Text_IO; 

package Polynomials is
    type Term is record
        x, y : Integer; 
        coef : Float; 
    end record; 

    -- forward declaration of List_Node so we can refer to it in List_Node_Ptr
    type List_Node; 
    type List_Node_Ptr is access List_Node; 
    
    -- List_Node is a singly linked list of Terms 
    type List_Node is record 
        t : Term; 
        next : List_Node_Ptr; 
    end record; 
    
    -- Polynomial points to the first element of the term list 
    -- and also tracks the number of terms in the list 
    type Polynomial is record 
        head : List_Node_Ptr; 
        count : Integer; 
    end record; 

    Null_Polynomial : constant  Polynomial := Polynomial'(head => null, count => 0); 
    
    function "+" (P : Polynomial; T : Term) return Polynomial;
    function "+" (P1, P2 : Polynomial)      return Polynomial;
    function "*" (P : Polynomial; T : Term) return Polynomial;
    function "*" (P1, P2 : Polynomial)      return Polynomial;
    function "=" (P1, P2 : Polynomial)      return Boolean;
    
    function Read (F : File_Type) return Term;
    function Read (F : File_Type) return Polynomial; 
    procedure Write (T : Term);
    procedure Write (P : Polynomial); 
end Polynomials;
