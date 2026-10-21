package body Polynomials  is
    -- we'll use this function to free individual nodes of temporary polynomials
    -- we no longer need 
    procedure Free_List_Node is new Ada.Unchecked_Deallocation(List_Node, List_Node_Ptr);

    -- our arithmetic functions create many temporary polynomials, 
    -- use this function to avoid a space leak 
    procedure Free_Polynomial(P : Polynomial) is 
        CurrNode : List_Node_Ptr := P.head; 
        NextNode : List_Node_Ptr := null; 
    begin 
        while CurrNode /= null loop
            NextNode := CurrNode.next; 
            Free_List_Node(CurrNode); 
            CurrNode := NextNode; 
        end loop; 
    end Free_Polynomial; 
    
    -- scan through the polynomial looking for the coefficient of the given
    -- term, return 0.0 if you don't find it
    function Find_Coefficient(P : Polynomial; X, Y : Integer) return Float is 
        CurrNode : List_Node_Ptr := P.head;  
    begin 
        while CurrNode /= null loop 
            if CurrNode.t.x = X and CurrNode.t.y = Y then 
                return CurrNode.t.coef; 
            end if; 
            CurrNode := CurrNode.next; 
        end loop; 
        return 0.0; 
    end Find_Coefficient; 
    
    -- copy the elements of a polynomial into a new polynomial 
    function Copy(P : Polynomial) return Polynomial is 
        OldNode : List_Node_Ptr := P.head; 
        NewNode : List_Node_Ptr := null; 
    begin 
        while OldNode /= null loop
            NewNode := new List_Node'(t => OldNode.t, next => NewNode); 
            OldNode := OldNode.next; 
        end loop; 
        return Polynomial'(head => NewNode, count => P.count); 
    end Copy; 
    
    -- modify polynomial P by replacing its X^X_Exp Y^Y_Exp node with a new
    -- node containing a different coefficient 
    procedure SetCoef(P : in out Polynomial; X_Exp, Y_Exp : Integer; Coef : Float) is
        -- need to keep previous node for when coef = 0.0 and we have to 
        -- delete the currnode without severing the list 
        PrevNode : List_Node_Ptr := null; 
        CurrNode : List_Node_Ptr := P.head; 
    begin 
        while CurrNode /= null loop
            if CurrNode.t.x = X_Exp and CurrNode.t.y = Y_Exp then 
                if Coef = 0.0 then 
                    -- decrease the polynomial count since we're going to delete a node 
                    P.count := P.count - 1; 
                    -- if we're still at the beginning of the list 
                    if PrevNode = null then P.head := CurrNode.next; 
                    -- otherwise skip over the current node 
                    else PrevNode.next := CurrNode.next; 
                    end if; 
                    -- now delete the current node
                    Free_List_Node(CurrNode); 
                -- if coeff /= 0
                else CurrNode.t.coef := Coef;
                end if; 
                -- since every exponent pair is unique in the list, we can now 
                -- exit the loop 
                exit;  
            end if; 
            PrevNode := CurrNode; 
            CurrNode := CurrNode.next; 
        end loop;  
    end SetCoef; 
    
    function "+" (P : Polynomial; T : Term) return Polynomial is
        coef : Float := Find_Coefficient(P, T.x, T.y); 
        -- copy of P which we'll either modify or extend 
        Result : Polynomial := Copy(P); 
    begin 
        -- if this term isn't in the polynomial P then add it to P's linked list
        if coef = 0.0 then 
            Result := Polynomial'(head => new List_Node'(T, Result.head), count => Result.count+1);
        else 
        -- if the term is already in P, then simply modify the coefficient in P2 
            SetCoef(Result, T.x, T.y, T.coef + coef);
        end if; 
        return Result;
    end "+";
    
    -- initialize Result to P1 and incrementally add each term of P2 
    function "+" (P1, P2 : Polynomial)      return Polynomial is 
        -- use OldResult so we can delete intermediate polynomials
        OldResult : Polynomial := Null_Polynomial; 
        Result : Polynomial := P1; 
        CurrNode : List_Node_Ptr := P2.head; 
    begin 
        while CurrNode /= null loop
            -- store old polynomial so we can free it in case this isn't 
            -- the last iteration of the loop 
            OldResult := Result; 
            Result := Result + CurrNode.t; 
            Free_Polynomial(OldResult); 
            CurrNode := CurrNode.next; 
        end loop; 
        return Result; 
    end "+"; 

    -- loop over the terms of the polynomial P, multiplying each one
    -- by the term T and appending the resultant NewTerm to the polynomial Result     
    function "*" (P : Polynomial; T : Term) return Polynomial is
        Result : Polynomial := Null_Polynomial; 
        CurrNode : List_Node_Ptr := P.head;         
        X_Exponent : Integer; 
        Y_Exponent : Integer; 
        Coef : Float; 
        NewTerm : Term; 
    begin 
        while CurrNode /= null loop
            -- when multiplying two terms:
            -- c1 x^i y^j * c2 x^l y^m 
            -- the result is:
            -- (c1*c2) x^(i+l) y^(j+m)
            X_Exponent := CurrNode.t.x + T.x; 
            Y_Exponent := CurrNode.t.y + T.y; 
            Coef := CurrNode.t.coef * T.coef; 
            NewTerm := Term'(x => X_Exponent, y => Y_Exponent, coef => Coef); 
            
            -- grow result by creating a new list_node which points to the previous 
            -- head as its next pointer 
            Result := Polynomial'(head => new List_Node'(t => NewTerm, next => Result.head), count => Result.count + 1);
            CurrNode := CurrNode.next; 
        end loop; 
        return Result; 
    end "*"; 
    
    -- multiplication of two polynomials implemented by repeatedly adding
    -- the polynomials generated through multiplying one term of P1 by all of P2
    function "*" (P1, P2 : Polynomial)      return Polynomial is 
        -- pointer used to iterate through P1 
        CurrNode : List_Node_Ptr := P1.head; 
        -- accumulate a result by multiplying each P2 by each term of P1 and
        -- adding to this variable 
        Result : Polynomial := Null_Polynomial; 
    begin 
        while CurrNode /= null loop
            Result := Result + (P2 * CurrNode.t); 
            CurrNode := CurrNode.next; 
        end loop; 
        return Result; 
    end "*"; 
    
    -- Loop through every term in P1 and check if its coefficient in P2 
    -- is the same. 
    -- Lastly, make sure P2 has no extra terms by checking that their lengths
    -- are the same. 
    function "=" (P1, P2 : Polynomial)      return Boolean is 
        CurrNode : List_Node_Ptr := P1.head; 
        P2_Coef : Float; 
    begin 
        while CurrNode /= null loop
            P2_Coef := Find_Coefficient(P2, CurrNode.t.x, CurrNode.t.y); 
            if P2_Coef /= CurrNode.t.coef then 
                return False; 
            else 
                CurrNode := CurrNode.next; 
            end if; 
        end loop; 
        -- if we've survived the loop, that means that every term in P1 has
        -- the same coefficient in P2. The only thing still required for 
        -- them to be equal is that they should have the same length. 
        return P1.count = P2.count; 
    end "="; 
    
    -- format of terms is "Float X Int Y Int"  
    function Read (F : File_Type) return Term is 
        X_Exp : Integer; 
        Y_Exp : Integer; 
        Coef : Float; 
        Char : Character; 
    begin 
        Get(File => F, Item => Coef); 
        Get(File => F, Item => Char); 
        Assert(Char = ' ', "Malformed input: expected space"); 
        Get(File => F, Item => Char); 
        Assert(Char = 'X', "Malformed input: expected 'X'"); 
        Get(File => F, Item => X_Exp);
        Get(File => F, Item => Char); 
        Assert(Char = ' ', "Malformed input: expected space");  
        Get(File => F, Item => Char); 
        Assert(Char = 'Y', "Malformed input: expected 'Y'"); 
        Get(File => F, Item => Y_Exp); 
        return Term'(x => X_Exp, y => Y_Exp, coef => Coef); 
    end Read; 
    
    -- Accumulate terms by growing the list pointed to by CurrHead 
    function Read (F : File_Type) return Polynomial is 
        CurrHead : List_Node_Ptr := null; 
        CurrTerm : Term; 
        Count : Integer := 0; 
    begin 
        while not (End_Of_Line(F) or End_Of_File(F)) loop
            CurrTerm := Read(F); 
            if CurrTerm.Coef /= 0.0 then 
                CurrHead := new List_Node'(t => CurrTerm, next => CurrHead); 
                Count := Count + 1; 
            end if; 
        end loop; 
        if End_Of_Line(F) then 
            Skip_Line(File => F); 
        end if; 
        return Polynomial'(head => CurrHead, count => Count); 
    end Read; 
    
    procedure Write (T : Term) is begin 
        -- Don't need to worry about coefficients of 0.0
        -- since they'll be pruned from the polynomial representation 
        -- Only print a coefficient of 1.0 if the x and y exponents are 0. 
        if T.coef /= 1.0 or (T.x = 0 and T.y = 0) then 
            Put(T.coef); 
        end if; 
        if T.x = 1 then 
            Put(" X"); 
        elsif T.x /= 0 then 
            Put(" X^"); 
            Put(T.x, 1); 
        end if; 
        if T.y = 1 then 
            Put(" Y"); 
        elsif T.y /= 0 then 
            Put (" Y^"); 
            Put (T.y, 1); 
        end if; 
    end Write; 
    
    -- print the polynomial by printing its terms one at a time 
    procedure Write (P : Polynomial) is 
        CurrNode : List_Node_Ptr := P.head; 
    begin 
        if CurrNode = null then
            -- a null polynomial corresponds to the constant 0 
            Put("0.0"); 
        else
            loop 
                -- print the current term 
                Write(CurrNode.t); 
                if CurrNode.next = null then exit; 
                else 
                    Put (" + "); 
                    CurrNode := CurrNode.next; 
                end if;
            end loop; 
        end if; 
        Put_Line(""); 
    end Write; 
end Polynomials;
