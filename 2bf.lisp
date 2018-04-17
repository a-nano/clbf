(uiop/package:define-package :clbf/2bf (:nicknames) (:use :cl) (:shadow)
                             (:import-from :cl-ppcre :scan)
                             (:import-from :clbf/clbf :bf-with-in)
                             (:export :2bf-do :2bf) (:intern))
(in-package :clbf/2bf)
;;don't edit above

(defun 2bf-dup () 
  (format nil "<[>+>+<<-]>>[<<+>>-]"))

(defun 2bf-push (num)
  (if (or (< num 0) (< 255 num)) (return-from 2bf-push nil))
  (format nil "~{~A~}>" (make-list num :initial-element "+")))

(defun 2bf-pop ()
  (format nil ".<"))



(defun get-token (str pos &optional token)
  (if (>= pos (length str)) 
      (return-from get-token (list :token (if token (coerce (reverse token) 'string) nil) :pos pos)))
  (let* ((ch (char str pos))
         (code (char-code ch)))
    (if (and (< 32 code) (< code 127)) ;; ASCII graphic character
        (get-token str (1+ pos) (cons ch token))
        (if (eq token nil)
            (get-token str (1+ pos) nil) ;; ignore non graphic character
            (list :token (string-upcase (coerce (reverse token)'string)) :pos pos))))) ;; return token and position

(defun tokenize (program &optional (pos 0) tokens)
  (let ((gotten (get-token program pos)))
    (if (getf gotten :token)
        (tokenize program (getf gotten :pos) (cons (getf gotten :token) tokens))
        (reverse tokens))))

(defun 2bf-core (token)
  (cond ((string= "POP" token) (2bf-pop))
        ((string= "DUP" token) (2bf-dup))
        ((scan "^\\d+" token)
         (let ((num (parse-integer token)))
           (if (<= num 255)
               (2bf-push num)
               nil))) ;; TODO error?
        (t "")))

(defun 2bf (program)
  (do* ((bf-program nil)
        (tokens (tokenize program))
        (token (pop tokens) (pop token)))
      ((null token) (format nil "~{~A~}" (reverse bf-program)))
    (push (2bf-core token) bf-program)))
  

(defun 2bf-do (program &key (in-stream *standard-input*) (out-stream *standart-output*))
  (with-open-stream (p (make-string-input-stream (2bf program)))
    (bf-with-in p)))
