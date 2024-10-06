#lang racket/gui
;Manuel Antonio Morales González A01664652
;Santiago Calderón Ortega A01663888
;David Alberto Padrones Sánchez A01663806
;Rodrigo Fernando Rivera Olea A01664716
(require racket/port)
(require racket/future)
(require "MyLexerPython.rkt" parser-tools/lex)

; Función que crea un archivo en el path
(define (create-file path)
  (define out (open-output-file path))
  (close-output-port out))

;; Make a frame by instantiating the frame% class
(define frame (new frame% [label "Example"]))

;; Function to handle file selection and processing
(define (select-files num-files)
  (define processed-files '())
  (define total-processing-time 0.0)
  (define futures '())

  ; Helper function to process each file
  (define (process-file file i)
    (when file
      (define input-contents (regexp-replace* #rx"#f" (port->string (open-input-file file) #:close? #t) " "))
      (mySintaxer input-contents)
      (define output-file (format "outputPython~a.html" i))
      (create-html-file file output-file)
      (measure-processing-time file output-file)))

  ; Launch futures for each file
  (for ([i (in-range num-files)])
    (let ([file (get-file)])
      (when file
        (define fut (future (lambda () (process-file file i))))
        (set! futures (cons fut futures))
        (set! processed-files (cons file processed-files)))))

  ; Wait for all futures to complete and accumulate processing times
  (for ([f futures])
    (define file-processing-time (touch f))
    (set! total-processing-time (+ total-processing-time file-processing-time)))

  (printf "Archivos procesados:~%")
  (for ([file processed-files])
    (printf "~a~%" file))
  (printf "Tiempo total de procesamiento: ~a segundos~%" total-processing-time))

;; Function to get number of files to process
(define (ask-number-of-files)
  (define dialog (new dialog%
                      [label "Enter number of files"]
                      [parent frame]
                      [width 300]
                      [height 150]))
  (define txt (new text-field%
                   [label "Number of files: "]
                   [parent dialog]))
  (new button%
       [label "OK"]
       [parent dialog]
       [callback (lambda (button event)
                   (let ([num-files (string->number (send txt get-value))])
                     (if (and num-files (integer? num-files) (> num-files 0))
                         (begin
                           (send dialog show #f)
                           (select-files num-files))
                         (printf "Invalid number of files\n"))))])
  (send dialog show #t))

;; Make a button in the frame
(new button% [parent frame]
             [label "Select Files"]
             ;; Callback procedure for a button click:
             [callback (lambda (button event) (ask-number-of-files))])

;; Show the frame by calling its show method
(send frame show #t)

(define lexico-status "")

(define token-colors
  (hash 'ASIGNACION "#FF00FF"
        'OPERADORES "#0000FF"
        'PUNTUACION "#1cc88a"
        'COMPARACION "#bee1ff"
        'ENTERO "#FFD700"
        'REAL "#A52A2A"
        'COMENTARIOSIMPLE "#c1c1c1"
        'COMENTARIOLARGO "#c1c1c1"
        'STRING "#16841D"
        'STRINGDOS "#16841D"
        'METODO "#c31bd6"
        'VARIABLE "#00008B"
        'CONDICIONAL "#00CED1"
        'BREAK "#00CED1"
        'FOR "#00CED1"
        'TRY "#00CED1"
        'TRUE "#00CED1"
        'FALSE "#00CED1"
        'RETURN "#00CED1"
        'WHILE "#00CED1"
        'OR "#00CED1"
        'AND "#00CED1"
        'IMPORT "#00CED1"
        'IN "#00CED1"
        'IS "#00CED1"
        'NOT "#00CED1"
        'GLOBAL "#00CED1"
        'PARENTESIS "#FF4500"
        'CORCHETES "#FF4500"
        'LLAVES "#FF4500"
        'ERROR "#FF0000"))

(define (processingSintaxer inputFile)
  
  (printf "Token    Tipo\n")
  
  (port-count-lines! inputFile)
  (let ([token-count 0]
        [error-found #f]
        [current-line 1]
        [error-line 0]) ; Variable para almacenar la línea del error
    (letrec ([one-line ; Se evalúa si lo que está en un punto específico del input está definido en nuestro analizador sintáctico. De serlo, se realiza una acción específica
              (lambda ()
                (let ([result (lexerAritmetico inputFile)])
                  (unless (equal? result 'EOF)
                    (set! token-count (+ token-count 1))
                    (printf "~a    |     " (token-value result))
                    (printf "~a\n" (token-name result))
                    (printf "\n")
                    
                    (if (equal? (token-name result) 'ERROR)
                        (begin
                          (set! error-line current-line) ; Actualiza la línea del error
                         
                          (set! error-found #t))
                        (printf ""))
                    
                    (when (equal? (token-name result) 'newline) ; Incrementa la línea actual al encontrar una nueva línea
                      (set! current-line (+ current-line 1)))
                    (one-line))))])
      (one-line))
    (if error-found
        (begin
          (set! lexico-status (format "Error: Lexico incorrecto en la línea ~a" error-line))
         )
        (begin
          (set! lexico-status "Lexico correcto")
          ))))

; Función que recibe el archivo de entrada y lo envía al analizador sintáctico
(define (mySintaxer inputFile)
  (processingSintaxer (open-input-string inputFile)))

; Se le aplica un provide para poder usarlo desde cualquier parte (exportarlo)
(provide mySintaxer)

(define (color-token token-name token-value)
  (let ([color (hash-ref token-colors token-name "#000000")]) ; Color por defecto es negro si no se encuentra el token
    (format "<span style=\"color:~a; font-size: large;\">~a</span>" color token-value)))

(define (colorize-contents contents)
  (let loop ([input (open-input-string contents)]
             [output (format "~a| " 1)]
             [line-number 1]) ; Inicializa el número de línea
    (let ([result (lexerAritmetico input)])
      (if (equal? result 'EOF)
          output
          (let* ([token-name (token-name result)]
                 [token-value (let ([val (token-value result)])
                                (if (symbol? val)
                                    (symbol->string val)
                                    (format "~a" val)))] ; Asegura que token-value es una cadena
                 [token-value (regexp-replace* #rx"#f" token-value " ")] ; Reemplaza #f por espacio
                 [colored-token (color-token token-name token-value)]
                 [formatted-token (string-append colored-token (if (equal? token-name 'newline) (format "<br>~a| " (begin0 (+ line-number 1) (set! line-number (+ line-number 1)))) ""))]) ; Incrementa el número de línea y añade el contador de líneas
            (loop input (string-append output formatted-token) line-number))))))

(define (create-html-file input-path output-path)
  (define input-contents (regexp-replace* #rx"#f" (port->string (open-input-file input-path) #:close? #t) " "))

  (define colored-contents (colorize-contents input-contents))

  (call-with-output-file output-path
    (lambda (output-port)
      (fprintf output-port "<!DOCTYPE html>\n")
      (fprintf output-port "<html>\n<head>\n<title>PythonTest</title>\n</head>\n<body>\n<pre>\n")
      (fprintf output-port "~a\n" colored-contents)
      (fprintf output-port "</pre>\n")
      (fprintf output-port "<div style=\"background-color: #000; color: #00FF00; padding: 20px; margin: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0, 255, 0, 0.5); font-family: 'Courier New', Courier, monospace; overflow-y: auto; height: 200px; \">\n")
      (fprintf output-port "<p>~a</p>\n" lexico-status)
      (fprintf output-port "</div>\n")
      (fprintf output-port "</body>\n</html>\n"))
    #:exists 'replace))

; Función para medir el tiempo de procesamiento
(define (measure-processing-time input-path output-path)
  (define start-time (current-inexact-milliseconds))
  (create-html-file input-path output-path)
  (define end-time (current-inexact-milliseconds))
  (define processing-time (/ (- end-time start-time) 1000.0)) ; Convierte de milisegundos a segundos
  processing-time)

(provide mySintaxer value-tokens op-tokens lexerAritmetico create-html-file measure-processing-time)

