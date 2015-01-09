;;; init.el --- Where all the magic begins
;;
;; Part of the Emacs Starter Kit
;;
;; This is the first thing to get loaded.
;;

;; load Org-mode from source when the ORG_HOME environment variable is set
(when (getenv "ORG_HOME")
  (let ((org-lisp-dir (expand-file-name "lisp" (getenv "ORG_HOME"))))
    (when (file-directory-p org-lisp-dir)
      (add-to-list 'load-path org-lisp-dir)
      (require 'org))))

;; load the starter kit from the `after-init-hook' so all packages are loaded
(add-hook 'after-init-hook
 `(lambda ()
    ;; remember this directory
    (setq starter-kit-dir
          ,(file-name-directory (or load-file-name (buffer-file-name))))
    ;; only load org-mode later if we didn't load it just now
    ,(unless (and (getenv "ORG_HOME")
                  (file-directory-p (expand-file-name "lisp"
                                                      (getenv "ORG_HOME"))))
       '(require 'org))
    ;; load up the starter kit
    (org-babel-load-file (expand-file-name "starter-kit.org" starter-kit-dir))

    ;;;;;;;;;;;;;; mark's init.el changes start here
    (starter-kit-install-if-needed 'cedit
                                   'color-theme
                                   'company
                                   'enh-ruby-mode
                                   'git-commit-mode
                                   'git-rebase-mode
                                   'markdown-mode
                                   'markdown-mode+
                                   'multi-web-mode
                                   'nlinum
                                   'osx-clipboard
                                   'ps-ccrypt
                                   'evil)

    ;;
    ;; center the frame on the screen
    ;;
    (if (window-system)
        (progn
          (setq my-pixel-width (nth 3 (assq 'geometry (car (display-monitor-attributes-list)))))
          (setq my-pixel-height (nth 4 (assq 'geometry (car (display-monitor-attributes-list)))))

          ;; subtract 5 cols / rows off of computed value to add room for window chrome
          (let ((cols (- (/ my-pixel-width (frame-char-width (selected-frame))) 5))
                (rows (- (/ my-pixel-height (frame-char-height (selected-frame))) 5))
                
                )
            (set-frame-size (selected-frame) cols rows)

            (let ((xpos (- (/ my-pixel-width 2) (/ (frame-pixel-width) 2)))
                  (ypos (- (/ my-pixel-height 2) (/ (frame-pixel-height) 2))))
              (set-frame-position (selected-frame) xpos ypos)
              (add-to-list 'initial-frame-alist '(width . cols))
              (add-to-list 'initial-frame-alist '(height . rows))
              )
            )
          (xterm-mouse-mode 0)
          )
      (progn
        (message "tty")
        ;; add tty-appropriate things here
        (xterm-mouse-mode 1)
        )
      )

    ;; customizations I want everywhere
    (menu-bar-mode 1)
    (color-theme-initialize)
    (if (window-system)
        (color-theme-snow)
      (color-theme-comidia))
    (setq ring-bell-function 'ignore)
    (cua-mode)
    (global-company-mode 1)
    (tool-bar-mode 0)

    (require 'ps-ccrypt)

    ;; ctrl-% jump to matching paren
    (defun goto-match-paren (arg)
      "Go to the matching parenthesis if on parenthesis, otherwise insert %.
vi style of % jumping to matching brace."
      (interactive "p")
      (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
            ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
            (t (self-insert-command (or arg 1))))
      )

    (global-set-key (kbd "C-%") 'goto-match-paren)
    (global-set-key (kbd "C-5") 'goto-match-paren)

    ;; make emacs save backup files in /tmp
    (setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
    (setq auto-save-file-name-transforms
          `((".*" ,temporary-file-directory t)))

    ;; purge old backup files
    (message "Deleting old backup files...")
    (let ((week (* 60 60 24 7))
          (current (float-time (current-time))))
      (dolist (file (directory-files temporary-file-directory t))
        (when (and (backup-file-name-p file)
                   (> (- current (float-time (fifth (file-attributes file))))
                      week))
          (message "%s" file)
          (delete-file file)))
      )

    ;; Keybonds for osx
    (if (eq system-type 'darwin)
        (global-set-key [(hyper a)] 'mark-whole-buffer)
      (global-set-key [(hyper v)] 'yank)
      (global-set-key [(hyper c)] 'kill-ring-save)
      (global-set-key [(hyper s)] 'save-buffer)
      (global-set-key [(hyper l)] 'goto-line)
      (global-set-key [(hyper w)]
                      (lambda () (interactive) (delete-window)))
      (global-set-key [(hyper z)] 'undo)
      (global-set-key [mouse-4] 'previous-line)
      (global-set-key [mouse-5] 'next-line)
      )    

    ;;;;;;;;;;;;;; mark's init.el changes end here
    )
 )

;;; init.el ends here
