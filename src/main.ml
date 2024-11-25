open Ast
let parse (s: string) : expr =
        let lexbuf = Lexing.from_string s in
        let ast = Parser.sentence Lexer.read lexbuf in
        ast

type tacitus_type = | TacNoun | TacVerb

module type Context = sig
        type t
        val empty : t

        (* Lookup variable binding, return error if not found *)
        val lookup : t -> string -> tacitus_type

        (* Add another variable binding *)
        val extend : t -> string -> tacitus_type -> t
end

module Context : Context = struct
        type t = (string * tacitus_type) list
        let empty = []

        let lookup context var = 
                try List.assoc var context
                with Not_found -> failwith "Undefined variable"

        let extend context var ty = (var, ty) :: context
end

(*open Context

let rec typeof context = function
        | LiteralNoun _ -> TacNoun
        | Monadic _ -> TacNoun
        | Dyadic _ -> TacNoun
        | Verb _ -> TacVerb
        | Assign (_, exp) -> typeof context exp
        | _ -> TacNoun
*)

let ht = [((SimpleVerb "Add"), (+));
 ((SimpleVerb "Star"), ( * )); 
 ((SimpleVerb "Divide"), (/))]

(*  [subst e v x] is [e] with [v] substituted for [x], that is, [e{v/x}].*)
let rec subst e v x = match e with
        | LiteralNoun (IArray _) -> e
        | LiteralNoun (FArray _) -> e
        | LiteralNoun (Id y) -> if x = y then v else e
        | Monadic (vb, n) -> Monadic (vb, subst n v x)
        | Dyadic (left, vb, right) -> Dyadic (subst left v x, vb, subst right v x)
        | Assign (y, e1, e2) -> 
                        let e1' = subst e1 v x in
                        if x = y
                        then Assign (y, e1', e2)
                        else Assign (y, e1', subst e2 v x)

let signum x = if x > 0 then 1 else (if x < 0 then -1 else 0)
let signum_f x = if x > 0.0 then 1.0 else (if x < 0.0 then -1.0 else 0.0)

let rec eval (e : expr) : expr = match e with
        | LiteralNoun _ -> e
        | Monadic (Fork (f, g, h), exp) -> eval_monadic_fork f g h (eval exp)
        | Monadic (Hook (f, g), exp) -> eval_monadic_hook f g (eval exp)
        | Monadic (ModVerb(v, adv), exp) -> eval_monadic_modverb v adv (eval exp)
        | Monadic (v, exp) -> eval_monad v (eval exp)
        | Dyadic (left, vb, right) -> eval_dyad left vb right
        | Assign (var, e1, e2) -> subst e2 (eval e1) var |> eval
        (*| _ -> failwith "Cannot evaluate" *)

and eval_monad m exp = match m, exp with
        | ModVerb(v, adv), exp -> eval_monadic_modverb v adv exp
        | SimpleVerb "Star", LiteralNoun (IArray iarr) -> LiteralNoun (IArray (List.map signum iarr))
        | SimpleVerb "Star", LiteralNoun (FArray farr) -> LiteralNoun (FArray (List.map signum_f farr))
        | SimpleVerb "Divide", LiteralNoun (IArray iarr) -> LiteralNoun (FArray (List.map (fun x -> 1.0 /. float_of_int(x)) iarr))
        | SimpleVerb "Divide", LiteralNoun (FArray farr) -> LiteralNoun (FArray (List.map (fun x -> 1.0 /. x) farr))
        | SimpleVerb "Tally", LiteralNoun (IArray iarr) -> LiteralNoun (IArray ([List.length iarr]))
        | SimpleVerb "Increment", LiteralNoun (IArray iarr) -> LiteralNoun (IArray (List.map (fun x -> x+1) iarr))
        | SimpleVerb "Increment", LiteralNoun (FArray farr) -> LiteralNoun (FArray (List.map (fun x -> x +. 1.0) farr))
        | _ -> failwith "Illegal simple monad"

and eval_monadic_modverb v adv exp = match adv, exp with 
        | Adverb "Insert", LiteralNoun (IArray iarr) -> LiteralNoun(IArray( [List.fold_right (List.assoc v ht) iarr 0] ))
        | _ -> failwith "Unimplemented adverb"

and eval_monadic_hook f g exp = eval_dyad exp f (eval_monad g exp)
and eval_monadic_fork f g h exp = eval_dyad (eval_monad f exp) g (eval_monad h exp)

and eval_dyad l dy r = match l, dy, r with
        | LiteralNoun(IArray larr), SimpleVerb "Add", LiteralNoun(IArray rarr) -> if List.length larr == List.length rarr then
                                                        LiteralNoun( IArray( List.map2 (+) larr rarr))
                                                        else failwith "array length mismatch"

        | LiteralNoun(IArray larr), SimpleVerb "Divide", LiteralNoun(IArray rarr) -> if List.length larr == List.length rarr then
                                                        LiteralNoun( IArray( List.map2 (/) larr rarr))
                                                        else failwith "array length mismatch"

        | LiteralNoun(FArray larr), SimpleVerb "Divide", LiteralNoun(FArray rarr) -> if List.length larr == List.length rarr then
                                                        LiteralNoun( FArray( List.map2 (/.) larr rarr))
                                                        else failwith "array length mismatch"
        | _ -> failwith "Illegal dyad"

let tacitus (s : string) : expr = 
        let e = parse s in
        (* typecheck e; *)
        eval e
