#lang racket

#|PROGRAMANDO EL ANALIZADOR LÉXICO DE PYTHON

Definimos el manejo de archivos, la ejecución del analizador sintáctico y el analizador léxico de nuestro lenguaje de programación

author: Santiago Calderón Ortega | Rodri

|#

;Importamos paqueteria
(require racket/port)
(require parser-tools/yacc
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

;Definimos los tokens del lenguaje de programación
(define-tokens value-tokens 
  (ENTERO REAL COMPARACION VARIABLE PARENTESIS STRING STRINGDOS METODO CORCHETES LLAVES PUNTUACION ASIGNACION OPERADORES
          COMENTARIOSIMPLE COMENTARIOLARGO BOOL RETURN WHILE OR AND IMPORT IN IS NOT MOD GLOBAL CONDICIONAL BREAK FOR TRY ERROR))

(define-empty-tokens op-tokens (newline espacios tab = + - * / ^ % EOF))

;Definimos las abreviaturas de los tokens
(define-lex-abbrevs
  [var_symbs     (:or (:or (:/ "a" "z") (:/ #\A #\Z) ) (:+ "_"))]
  [digit      (:/ #\0 #\9)])

;Definimos el lexer del lenguaje de programación
(define lexerAritmetico
  (lexer
   [(eof) 'EOF]
   [(:or #\backspace #\page #\return #\vtab) (lexerAritmetico input-port)]
   [(:or #\space #\tab) (token-espacios)]
   [#\newline (token-newline)]
   ["=" (token-ASIGNACION (string->symbol lexeme))]
   [(:or "+" "-" "*" "/" "^" "%") (token-OPERADORES (string->symbol lexeme))]
   [(:or "." ":" "&" ",") (token-PUNTUACION (string->symbol lexeme))]
   [(:or "<" ">")(token-COMPARACION (string->symbol lexeme))]
   [(:or "(" ")") (token-PARENTESIS lexeme)]
   [(:or "[" "]") (token-CORCHETES lexeme)]
   [(:or "{" "}") (token-LLAVES lexeme)]
   [(:: (:* "-") (:+ digit)) (token-ENTERO (string->number lexeme))]
   [(:: (:* "-") (:+ digit) (:* (:: #\. (:+ digit) ))) (token-REAL (string->number lexeme))]
   [(:: (:* "-") (:+ digit) (:* (:: #\. (:+ digit) )) (:* (:: (:: #\E (:* "-") ))) (:+ digit) ) (token-REAL (string->number lexeme))]
   [(:or "if" "elif" "else") (token-CONDICIONAL (string->symbol lexeme))]
   ["break" (token-BREAK (string->symbol lexeme))]
   ["for" (token-FOR (string->symbol lexeme))]
   ["try" (token-TRY (string->symbol lexeme))]
   [(:or "true" "false") (token-BOOL (string->symbol lexeme))]
   ["return" (token-RETURN (string->symbol lexeme))]
   ["while" (token-WHILE (string->symbol lexeme))]
   ["or" (token-OR (string->symbol lexeme))]
   ["and" (token-AND (string->symbol lexeme))]
   ["import" (token-IMPORT (string->symbol lexeme))]
   ["in" (token-IN (string->symbol lexeme))]
   ["is" (token-IS (string->symbol lexeme))]
   ["not" (token-NOT (string->symbol lexeme))]
   ["global" (token-GLOBAL (string->symbol lexeme))]
   [(concatenation  (repetition 1 +inf.0 #\#) (repetition 0 +inf.0 (char-range #\space #\~) )) (token-COMENTARIOSIMPLE (string->symbol lexeme))]
   [(concatenation  (repetition 3 +inf.0 #\") (repetition 0 +inf.0 any-char) (repetition 3 +inf.0 #\")) (token-COMENTARIOLARGO (string->symbol lexeme))]
   [(concatenation  (repetition 1 1 #\") (repetition 0 +inf.0 (union (char-range #\space #\!) (char-range #\# #\~) )) (repetition 1 1 #\")) (token-STRING (string->symbol lexeme))]
   [(concatenation  (repetition 1 1 #\') (repetition 0 +inf.0 (union (char-range #\space #\!) (char-range #\# #\~) ) ) (repetition 1 1 #\')) (token-STRINGDOS (string->symbol lexeme))]
   [(concatenation (union (char-range #\a #\z) (char-range #\A #\Z)) (repetition 0 +inf.0 (union (char-range #\a #\z) (char-range #\A #\Z) (char-range #\0 #\9) (:+ "_"))) #\() (token-METODO (string->symbol lexeme))]   
   [(concatenation (union (char-range #\a #\z) (char-range #\A #\Z)) (repetition 0 +inf.0 (union (char-range #\a #\z) (char-range #\A #\Z) (char-range #\0 #\9) (:+ "_")))) (token-VARIABLE (string->symbol lexeme))]   
   [(:: any-char) (token-ERROR (string->symbol lexeme))]
   )
  )


;Usamos provide para permitir que una función en Racket pueda ser utilizada por llamadas externas
;Es decir, para usarlo como paqueteria propia
(provide value-tokens op-tokens lexerAritmetico)



