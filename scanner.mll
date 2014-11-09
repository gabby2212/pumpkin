{ 
    open Parser
    open Utils

    let indent_stack = Stack.create()
}

let alpha = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let id  = alpha (alpha | digit | '_')*
let num = ['-' '+']? digit* ['.']? digit+ (['e' 'E']['-' '+']? digit+)?
let string = '"' [^ '"' '\']*('\' '.' [^ '"' '\']*)* '"'
let whitespace = [' ' '\t']*

rule token = parse
    [' ' '\r']     { token lexbuf }
    | "//"         { single_comment lexbuf }
    | "/*"         { block_comment lexbuf }
    | ['\r' '\n']+ { indent lexbuf } (* check line numbers eventually *)
    | [' ' 't']    { token lexbuf }

    | '(' { LPAREN }
    | ')' { RPAREN }
    | '[' { LBRACK }
    | ']' { RBRACK }
    | ',' { COMMA }
    | ':' { COLON }
    | '=' { ASSIGN }
    

    | "$"(['0'-'9']+ as lxm) { TUPALACC(lxm) }
    | "=>"                   { DEFARROW }
    | "->"                   { TYPEARROW }
    | '|'                    { GUARD }

    | "|>"                   { FPIPE }
    | "<|"                   { BPIPE }
    | ">>"                   { RCOMPOSE }
    | "<<"                   { FCOMPOSE }
    | "::"                   { CONS }

    | '+' { PLUS }
    | '-' { MINUS }
    | '*' { TIMES }
    | '/' { DIVIDE }
    | '%' { MODULO }
    
    | "is"  | "==" { EQ }
    | "and" | "&&" { AND }
    | "or"  | "||" { OR }
    | "not" | '!'  { NOT }
    | "!="         { NEQ }
    | '>'          { GT }
    | '<'          { LT }
    | ">="         { GEQ }
    | "<="         { LEQ }

    | "if"   { IF}
    | "else" { ELSE}

    | "val "id as lxm { ID(lxm) }
    | num             { NUM(num) }
    | string          { STRING(lxm)}
    | eof             { EOF }
    | _ as char       { raise (Failure("illegal character " ^ Char.escaped char)) }

and single_comment = parse
    '\n' { token lexbuf }
    | _ { comment lexbuf }

and block_comment = parse
    "*/" { token lexbuf }
    | _ { comment lexbuf }

and indent = parse
    [' ' '\t']* as indt
        {
            let indt_len = (String.length indt) in
            let top_len = (Stack.top indent_stack) in
            if indt_len > top_len then
                Stack.push indt_len indent_stack;
                INDENT
            else if indt_len = top_len then
                NEWLINE
            else
                let decrement =
                    let rec helper inc =
                        if (Stack.top indent_stack) > len then 
                            Stack.pop indent_stack;
                            helper (inc + 1)
                        else if (Stack.top indent_stack) < len then -1
                        else inc
                    in helper 0
                in 
                if decrement == -1 then raise (Failure("indent level error"))
                else DEINDENT(decrement)
        }
