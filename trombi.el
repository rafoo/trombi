;;; trombi.el --- A game for learning faces

;;; Copyright (C) 2014 Raphaël Cauderlier <cauderlier@crans.org>

;;; Author: Raphaël Cauderlier <cauderlier@crans.org>

;;; Version: 0.1

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; This file is *NOT* part of GNU Emacs.

;;; Commentary:

;;; Installation:
;; Add these lines to your Emacs init file :
; (add-to-list 'load-path "<path-to-trombi>/")
; (require 'trombi)

;; Put the pictures in a directory.
;; Customize the variable `trombi-dir'
;; with the path of the directory containing the pictures.
;; run M-x trombi-init
;; it will ask you for the name corresponding to each picture
;; Customize and save the variable `trombi-ids-name'
;; play this game by the command
;; M-x trombi-play

;; Description:
;; Trombi is a game for learning names associated to pictures,
;; it chooses pictures at random in the directory `trombi-dir',
;; displays them with `find-file' and ask for the corresponding names.
;; It finally displays the success rate.

;;; Code:

(defgroup trombi nil
  "Trombi is a game for learning faces."
  :group 'game)

(defcustom trombi-extension "JPG"
  "Extension of images for trombi, whitout a dot.
Only files ending with this will be used.
This extension is also troncated in `trombi-init'."
  :group 'trombi)

(defcustom trombi-dir "~/trombi/photos"
  "Directory of the pictures for trombi."
  :group 'trombi)

(defun trombi-ids ()
  "List student ids."
  (let ((files (file-name-all-completions "" trombi-dir))
        res)
    (dolist (f files)
      (when (string-match (format "\\(.*\\)\\.%s" trombi-extension) f)
        (add-to-list 'res (match-string 1 f)))
      )
    res)
  )


(defcustom trombi-ids-name nil
  "Association list of ids and names.
This is used by trombi to check answers."
  :group 'trombi)

(defun trombi-init ()
  "Initialize `trombi-ids-name'."
  (interactive)
  (dolist (id (trombi-ids))
    (find-file (format "%s/photos/%s.%s" trombi-dir id trombi-extension))
    (add-to-list 'trombi-ids-name
                 (cons id (read-string (format "%s: " id))))))

(defvar trombi-last-name nil
  "Name associated to the last picture displayed by trombi.")

(defun trombi-play-once ()
  "Display a random trombi image and prompt for a name.
Return t if the given name is associated to the image,
nil otherwise."
  (if trombi-ids-name
      (let* ((i (random (length trombi-ids-name)))
             (id-name (nth i trombi-ids-name))
             (id (car id-name))
             (name (cdr id-name)))
        (setq trombi-last-name name)
        (find-file (format "%s/photos/%s.%s" trombi-dir id trombi-extension))
        (string= name (read-string "Student name: "))
        )
    (error "The list `trombi-ids-name' is empty
you can initialize it with the command `trombi-init'
and save it with by customizing `trombi-ids-name'")))

(defun trombi-play (n)
  "Start a trombi game with N rounds."
  (interactive "nNumber of rounds: ")
  (let ((i n)
        (success 0))
    (while (> i 0)
      (message (if (trombi-play-once)
                   (progn
                      (setq success (+ 1 success))
                      "Yes!")
                 (format "No! Name was %s." trombi-last-name)))
      (sit-for 1)
      (setq i (- i 1)))
    (message (format "Game finished with a score of %s/%s." success n))))

(provide 'trombi)
;;; trombi.el ends here
