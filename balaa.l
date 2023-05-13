;;; balaa.l --- Thorough Arabic Stemming tester
;;;
;; Copyright (C) 2023 Salih Muhammed

;; Author: Salih Muhammed <salhghd7@gmail.com>
;; Created: 12 May 2023
;; URL: https://github.com/lugha/balaa


(load "samples.l")
(sb-posix:chdir "/home/l/gits/arch/balaa/stemmers/")

(defstruct stemmer
  name
  call
  cmd)

(defun read-file-as-string (infile)
  (with-open-file (instream infile :direction :input :if-does-not-exist nil)
    (when instream
      (let ((string (make-string (file-length instream))))
        (read-sequence string instream)
        string))))

(defparameter *my-timings* nil)
                                          

(defun run-python-stemmer (cmd word)
  (setq word (format nil (read-file-as-string cmd) word))
  (let* ((output-stream (make-string-output-stream))
         (process (sb-ext:run-program "/usr/bin/python"
                                      (list "-c" word)
                                      :output output-stream)))
    (process-wait process)
    (let ((output-string (get-output-stream-string output-stream)))
      (close output-stream)
      (string-trim
      '(#\Space #\Newline #\Backspace #\Tab
        #\Linefeed #\Page #\Return #\Rubout)
      output-string))))


(defun run-cli-stemmer (cmd word)
  (let* ((output-stream (make-string-output-stream))
         (process (sb-ext:run-program cmd
                                      (list word)
                                      :output output-stream)))
    (process-wait process)
    (let ((output-string (get-output-stream-string output-stream)))
      (close output-stream)
      (string-trim
      '(#\Space #\Newline #\Backspace #\Tab
        #\Linefeed #\Page #\Return #\Rubout)
      output-string))))


(defun balaa ()
  (let* ((stemmers (list
                    (make-stemmer :name "Mohamed Eldesouki"
                                  :call 'run-python-stemmer
                                  :cmd
                                  "stemmers/arabic_processing_cog.py")
                    (make-stemmer :name "ntlk"
                                  :call 'run-python-stemmer
                                  :cmd
                                  "stemmers/ntlk.py")
                    (make-stemmer :name "Snowball"
                                  :call 'run-cli-stemmer
                                  :cmd "/home/l/gits/balaa/stemmers/slight")
                    )))
    (do* ((stemmer stemmers (cdr stemmer))
          (s (car stemmer) (car stemmer)))
         ((null stemmer))
      (format t "~%Testing: ~A~%" (stemmer-name s))
      (do* ((lst *samples* (cdr lst))
            (morph (car (car lst)) (car (car lst))))
           ((null lst))
        (format t "Morth: ~A~%~%" morph)
        (do* ((word (cdr (car lst)) (cdr word))
              (wrong 0))
             ((null word) (format t "~%~A:OUT-OF:~A~%~%" (- (length (cdr (car lst))) wrong)
                                  (length (cdr (car lst)))))
          (let* ((run (get-internal-run-time))
                 (real (get-internal-real-time)))
            (multiple-value-prog1 (funcall (stemmer-call s) (stemmer-cmd s) (car (car word)))
              (push (cons (- (get-internal-run-time) run)
                          (- (get-internal-real-time) real))
                    *my-timings*))
            (let ((got (funcall (stemmer-call s) (stemmer-cmd s) (car (car word))))
                  (wanted (car (cdr (car word)))))
              (if (not (string-equal got wanted))
                  (progn
                    (format t "Got ~A wanted ~A~%" got wanted)
                    (setf wrong (+ wrong 1)))))
            (format t "Time: ~A~%" (/ (- (get-internal-real-time) real) internal-time-units-per-second 0.001))))))))
