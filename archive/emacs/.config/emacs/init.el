;; Basic emacs config
;;;;;;;;;;;;;;;;;;;;;

;; Config the backup/temp files dir
(setq backup-directory-alist `(("." . "~/.config/emacs/saves")))


;; Simple UI tweeks
;;;;;;;;;;;;;;;;;;;

;;disable splash screen and startup message
(setq inhibit-startup-message t) 
(setq initial-scratch-message nil)

;; Turn off the windows dressing
(menu-bar-mode -1)
;; not valid with non x-window setup
;; (tool-bar-mode -1)
;; (toggle-scroll-bar -1)
;; Turn off syntax highlighting
(global-font-lock-mode 0)
;; Status line
(setq-default mode-line-format
              (list
               ;; day and time
               '(:eval (propertize (format-time-string " %b %d %H:%M ")
                                   'face 'font-lock-builtin-face))

               ;; the buffer name; the file name as a tool tip
               '(:eval (propertize " %b "
                                   'face 'font-lock-builtin-face
                                   'help-echo (buffer-file-name))

                '(:eval (propertize (substring vc-mode 5)
                                   'face 'font-lock-builtin-face))

               ;; the current major mode
               (propertize " %m " 'face 'font-lock-builtin-face)
               ;;minor-mode-alist
               )))


;; Programming tweeks
;;;;;;;;;;;;;;;;;;;;;

;;python
(add-hook 'python-mode-hook
    (lambda ()
      (linum-mode)
      (setq tab-width 4)))
