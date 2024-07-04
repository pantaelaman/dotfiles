(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
(bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)

(setq straight-use-package-by-default t)

(use-package zerodark-theme
  :config (load-theme 'zerodark))

(use-package doom-modeline
  :init  (doom-modeline-mode 1)
  :custom ((doom-modeline-height 20)
	   (doom-modeline-window-width-limit 80)
	   (doom-modeline-project-detection 'auto)
	   (doom-modeline-lsp-icon t)
	   (doom-modeline-icon t)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package magit)

(use-package multiple-cursors
  :config (define-key mc/keymap (kbd "<return>") nil))

(use-package expand-region)

(use-package hydra)

(use-package pcre2el
  :straight (pcre2el :type git :host github :repo "joddie/pcre2el"))

(use-package helm
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files))
  :config (helm-mode 1))

(add-to-list 'load-path (expand-file-name "straight/repos/lsp-mode" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "straight/repos/lsp-mode/clients" user-emacs-directory))

(use-package avy)

;; *** LSP ***

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((rust-mode . lsp)
   (java-mode . lsp)
   (js-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-enable t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-update-mode "line")
  (setq lsp-ui-sideline-delay 0))
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-error-list)
(use-package flycheck)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

;; LSP langs

(use-package lsp-java)
(use-package rustic)

;; *** avy ***
;; much thanks to https://karthinks.com/software/avy-can-do-anything/

;; (setq avy-style 'words)
(setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o))
;; (avy-setup-default)

(defun avy-action-kill-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (kill-whole-line))
  (select-window
   (cdr
    (ring-ref avy-ring 0)))
  t)

(defun avy-action-copy-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (cl-destructuring-bind (start . end)
        (bounds-of-thing-at-point 'line)
      (copy-region-as-kill start end)))
  (select-window
   (cdr
    (ring-ref avy-ring 0)))
  t)

(defun avy-action-yank-whole-line (pt)
  (avy-action-copy-whole-line pt)
  (save-excursion (yank))
  t)

(defun avy-action-teleport-whole-line (pt)
  (avy-action-kill-whole-line pt)
  (save-excursion (yank)) t)

(defun avy-action-mark-t-char (pt)
  (activate-mark)
  (goto-char pt))

(setq avy-dispatch-alist
      '((?k . avy-action-kill-stay)
	(?K . avy-action-kill-whole-line)
	(?x . avy-action-kill-move)
	(?p . avy-action-teleport)
	(?P . avy-action-teleport-whole-line)
	(?m . avy-action-mark)
	(?  . avy-action-mark-to-char)
	(?q . avy-action-copy)
	(?Q . avy-action-copy-whole-line)
	(?y . avy-action-yank)
	(?Y . avy-action-yank-whole-line)
	(?l . avy-action-ispell)
	(?z . avy-action-zap-to-char)))

(define-key isearch-mode-map (kbd "M-m") 'avy-isearch)

;; *** kak ***

(defvar-keymap kak-command-map
  "f"
  (define-keymap
    "f" #'helm-find-files
    "w" #'save-buffer)
  "l" lsp-command-map
  "c" mode-specific-map
  "DEL" ctl-x-map
  "h" help-map
  "RET" #'helm-M-x)

(define-globalized-minor-mode kak-pcre-mode pcre-mode
  (lambda () (pcre-mode 1)))

(kak-pcre-mode 1)

(defun kak-enter-insert ()
  (interactive)
  (kak-normal-mode 0)
  (kak-insert-mode 1))

(defun kak-exit-insert ()
  (interactive)
  (kak-insert-mode 0)
  (kak-normal-mode 1))

(defun kak-next-char (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (forward-char num))

(defun kak-prev-char (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (backward-char num))

(defun kak-next-line (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (next-line num))

(defun kak-prev-line (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (previous-line num))

(defun kak-next-char-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (forward-char num))

(defun kak-prev-char-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (backward-char num))

(defun kak-next-line-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (next-line num))

(defun kak-prev-line-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (previous-line num))

(defun kak-next-word (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (kak-next-word-extend num))

(defun kak-next-word-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (forward-word num))

(defun kak-prev-word (&optional num)
  (interactive "p")
  (when mark-active (deactivate-mark))
  (kak-prev-word-extend num))

(defun kak-prev-word-extend (&optional num)
  (interactive "p")
  (unless mark-active (set-mark (point)))
  (backward-word num))

(defun kak-append-end ()
  (interactive)
  (when mark-active (deactivate-mark))
  (end-of-line)
  (kak-enter-insert))

(defun kak-insert-start ()
  (interactive)
  (when mark-active (deactivate-mark))
  (kak-goto-start)
  (kak-enter-insert))

(defun kak-goto-start ()
  (interactive)
  (when mark-active (deactivate-mark))
  (back-to-indentation))

(defun kak-goto-beginning ()
  (interactive)
  (when mark-active (deactivate-mark))
  (beginning-of-line))

(defun kak-goto-end ()
  (interactive)
  (when mark-active (deactivate-mark))
  (end-of-line))

(defun kak-goto-buffer-end ()
  (interactive)
  (when mark-active (deactivate-mark))
  (goto-char (point-max)))

(defun kak-goto-buffer-start ()
  (interactive)
  (when mark-active (deactivate-mark))
  (goto-char (point-min)))

(defun kak-goto-start-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (back-to-indentation))

(defun kak-goto-beginning-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (beginning-of-line))

(defun kak-goto-end-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (end-of-line))

(defun kak-goto-buffer-start-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (goto-char (point-min)))

(defun kak-goto-buffer-end-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (goto-char (point-max)))

(defun kak-goto-line (num)
  (interactive "N")
  (when mark-active (deactivate-mark))
  (goto-line num))

(defun kak-goto-line-extend (num)
  (interactive "N")
  (unless mark-active (set-mark (point)))
  (goto-line num))

(defun kak-open-below-passive (&optional num)
  (interactive "p")
  (save-excursion
    (end-of-line)
    (newline-and-indent num)
    (previous-line)))

(defun kak-open-above-passive (&optional num)
  (interactive "p")
  ;; save-excursion doesn't work here since we're inserting before it
  (let ((pt (- (buffer-size) (point))))
    (dotimes (i (or num 1))
      (beginning-of-line)
      (newline)
      (previous-line)
      (indent-according-to-mode))
    (goto-char (- (buffer-size) pt))))

(defun kak-open-below (&optional num)
  (interactive "p")
  (end-of-line)
  (newline-and-indent num)
  (kak-enter-insert))

(defun kak-open-above (&optional num)
  (interactive "p")
  (dotimes (i num)
    (beginning-of-line)
    (newline)
    (previous-line)
    (indent-according-to-mode))
  (kak-enter-insert))

(defun kak-open-here-passive ()
  (interactive)
  (kak-open-above-passive 1)
  (kak-open-below-passive 1))

(defun kak-open-here ()
  (interactive)
  (kak-open-here-passive)
  (kak-enter-insert))

(defun kak-select-line (&optional num)
  (interactive "p")
  (beginning-of-line)
  (set-mark (point))
  (search-forward "\n" nil t num))

(defun kak-select-to-end ()
  (interactive)
  (when mark-active (deactivate-mark))
  (kak-select-to-end-extend))

(defun kak-select-to-end-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (search-forward "\n" nil t))

(defun kak-kill ()
  (interactive)
  (if mark-active
      (kill-region 0 0 t)
    (delete-char 1 t)))

(defun kak-delete ()
  (interactive)
  (if mark-active
      (delete-region (point) (mark))
    (delete-char 1)))

(defun kak-change ()
  (interactive)
  (kak-kill)
  (kak-enter-insert))

(defun kak-copy ()
  (interactive)
  (kill-ring-save (point) (mark)))

(defun kak-yank (&optional num)
  (interactive "p")
  (yank num))

(defun kak-flip-region ()
  (interactive)
  (when mark-active
    (let ((old-mark (mark)))
      (set-mark (point))
      (goto-char old-mark))))

(defun kak-deselect-region ()
  (interactive)
  (when mark-active (deactivate-mark)))

(defun kak-goto-visible-top ()
  (interactive)
  (when mark-active (deactivate-mark))
  (move-to-window-line 0))

(defun kak-goto-visible-bottom ()
  (interactive)
  (when mark-active (deactivate-mark))
  (move-to-window-line -1))

(defun kak-goto-visible-middle ()
  (interactive)
  (when mark-active (deactivate-mark))
  (move-to-window-line nil))

(defun kak-goto-visible-top-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (move-to-window-line 0))

(defun kak-goto-visible-bottom-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (move-to-window-line -1))

(defun kak-goto-visible-middle-extend ()
  (interactive)
  (unless mark-active (set-mark (point)))
  (move-to-window-line nil))

(defun kak-clear-cursors ()
  (interactive)
  (multiple-cursors-mode 0))

(defun kak-till-char (char &optional num)
  (interactive "c\np")
  (when mark-active (deactivate-mark))
  (kak-till-char-extend char num))

(defun kak-till-char-extend (char &optional num)
  (interactive "c\np")
  (unless mark-active (set-mark (point)))
  (search-forward (char-to-string char) nil nil num)
  (backward-char))

(defun kak-till-char-back (char &optional num)
  (interactive "c\np")
  (when mark-active (deactivate-mark))
  (search-backward (char-to-string char) nil nil num))

(defun kak-till-char-back-extend (char &optional num)
  (interactive "c\np")
  (unless mark-active (set-mark (point)))
  (search-backward (char-to-string char) nil nil num)
  (forward-char))

(defun kak-replace (char)
  (interactive "c")
  (delete-char 1)
  (insert char)
  (backward-char))

(defun kak-viewport-middle ()
  (interactive)
  (recenter nil))

(defun kak-viewport-top ()
  (interactive)
  (recenter 1))

(defun kak-viewport-bottom ()
  (interactive)
  (recenter -2))

(defun kak-viewport-up (&optional num)
  (interactive "p")
  (scroll-down num)) ;; for appropriate cursor behaviour

(defun kak-viewport-down (&optional num)
  (interactive "p")
  (scroll-up num))

(defun kak-viewport-left (&optional num)
  (interactive "p")
  (scroll-right num))

(defun kak-viewport-right (&optional num)
  (interactive "p")
  (scroll-left num))

(defun kak-other-viewport-up (&optional num)
  (interactive "p")
  (scroll-other-window-down num))

(defun kak-other-viewport-down (&optional num)
  (interactive "p")
  (scroll-other-window num))

;; this function's purpose is to not ring the bell when exiting hydras
(defun kak-nothing () (interactive))

(defhydra kak-expand-hydra ()
  "expand selection"
  ("M-a" #'er/mark-outside-pairs)
  ("M-i" #'er/mark-inside-pairs)
  ("'" #'er/mark-inside-quotes)
  ("M-'" #'er/mark-outside-quots)
  ("w" #'er/mark-word)
  ("s" #'er/mark-symbol)
  ("M-s" #'er/mark-symbol-with-prefix)
  ("/" #'er/mark-comment)
  ("(" #'er/mark-method-call)
  ("." #'er/mark-url)
  ("@" #'er/mark-email)
  ("f" #'er/mark-defun)
  ("p" #'er/mark-paragraph)
  ("RET" #'kak-nothing :exit t))

(defhydra kak-viewport-hydra ()
  "viewport"
  ("v" #'kak-viewport-middle :exit t :hint centre)
  ("t" #'kak-viewport-top :exit t :hint top)
  ("b" #'kak-viewport-bottom :exit t :hint bottom)
  ;; special directional callbacks for finetuned control
  ("n" #'kak-viewport-left)
  ("e" #'kak-viewport-down)
  ("i" #'kak-viewport-up)
  ("o" #'kak-viewport-right)
  ;; counterintuitive directions
  ("N" #'scroll-right)
  ("E" #'scroll-up)
  ("I" #'scroll-down)
  ("O" #'scroll-left)
  ("RET" #'kak-nothing :exit t))

(defhydra kak-other-viewport-hydra ()
  "other viewport"
  ("e" #'kak-other-viewport-down)
  ("i" #'kak-other-viewport-up)
  ("E" #'scroll-other-window)
  ("I" #'scroll-other-window-down)
  ("RET" #'kak-nothing :exit t))

(defhydra kak-mark-hydra ()
  "mark"
  ("m" #'avy-goto-char-timer)
  ("w" #'avy-goto-word-1)
  ("W" #'avy-goto-word-0)
  ("." #'avy-goto-symbol-1)
  ("h" #'avy-goto-line))

(define-minor-mode kak-normal-mode
  "Kakoune Normal Mode"
  :lighter " normal"
  :keymap
  (define-keymap :full t
    "a" 'undefined
    "A" #'kak-append-end
    "b" #'kak-prev-word
    "B" #'kak-prev-word-extend
    "c" #'kak-change
    "C" #'mc/mark-next-lines
    "d" #'kak-kill
    "D" 'undefined
    "M-d" #'kak-delete
    "e" #'kak-next-line
    "E" #'kak-next-line-extend
    "f" 'undefined
    "F" 'undefined
    "g"
    (define-keymap
      "n" #'kak-goto-start
      "e" #'kak-goto-buffer-end
      "i" #'kak-goto-buffer-start
      "o" #'kak-goto-end
      "h" #'kak-goto-beginning
      "g" #'kak-goto-line
      "t" #'kak-goto-visible-top
      "b" #'kak-goto-visible-bottom
      "m" #'kak-goto-visible-middle)
    "G"
    (define-keymap
      "n" #'kak-goto-start-extend
      "e" #'kak-goto-buffer-end-extend
      "i" #'kak-goto-buffer-start-extend
      "o" #'kak-goto-end-extend
      "h" #'kak-goto-beginning-extend
      "g" #'kak-goto-line-extend
      "t" #'kak-goto-visible-top-extend
      "b" #'kak-goto-visible-bottom-extend
      "m" #'kak-goto-visible-middle-extend)
    "h" #'kak-open-below
    "H" #'kak-open-above
    "M-h" #'kak-open-below-passive
    "M-H" #'kak-open-above-passive
    "i" #'kak-prev-line
    "I" #'kak-prev-line-extend
    "M-i" #'kak-expand-hydra/body
    "M-a" #'kak-expand-hydra/body
    "j" 'undefined
    "J" 'undefined
    "k" #'kak-enter-insert
    "K" #'kak-insert-start
    "l" 'undefined
    "L" 'undefined
    "M-l" #'kak-select-to-end
    "M-L" #'kak-select-to-end-extend
    "m" #'avy-goto-char-timer
    "M" #'kak-mark-hydra/body
    "n" #'kak-prev-char
    "N" #'kak-prev-char-extend
    "o" #'kak-next-char
    "O" #'kak-next-char-extend
    "p" #'kak-open-here
    "M-p" #'kak-open-here-passive
    "P" 'undefined
    "q" #'kak-copy
    "Q" 'undefined
    "r" #'kak-replace
    "R" #'query-replace
    "s" #'mc/mark-all-in-region-regexp
    "S" 'undefined
    "t" #'kak-till-char
    "T" #'kak-till-char-extend
    "M-t" #'kak-till-char-back
    "M-T" #'kak-till-char-back-extend
    "u" #'undo
    "U" 'undefined
    "v" #'kak-viewport-hydra/body
    "V" #'kak-other-viewport-hydra/body
    "w" #'kak-next-word
    "W" #'kak-next-word-extend
    "x" #'kak-select-line
    "X" 'undefined
    "y" #'kak-yank
    "Y" 'undefined
    "z" 'undefined
    "Z" 'undefined
    "1" #'digit-argument
    "2" #'digit-argument
    "3" #'digit-argument
    "4" #'digit-argument
    "5" #'digit-argument
    "6" #'digit-argument
    "7" #'digit-argument
    "8" #'digit-argument
    "9" #'digit-argument
    "0" #'digit-argument
    "!" 'undefined
    "@" 'undefined
    "#" 'undefined
    "$" 'undefined
    "%" 'undefined
    "^" 'undefined
    "&" 'undefined
    "*" 'undefined
    "(" 'undefined
    ")" 'undefined
    "[" 'undefined
    "]" 'undefined
    "{" 'undefined
    "}" 'undefined
    "|" 'undefined
    "\\" 'undefined
    ";" #'kak-deselect-region
    "M-;" #'kak-flip-region
    ":" #'helm-M-x
    "'" 'undefined
    "\"" 'undefined
    "," #'kak-clear-cursors
    "." 'undefined
    "<" 'undefined
    ">" 'undefined
    "/" #'isearch-forward
    "M-/" #'isearch-backward
    "?" 'undefined
    "_" 'undefined
    "-" 'undefined
    "=" #'universal-argument
    "+" 'undefined
    "`" 'undefined
    "~" #'negative-argument
    "<SPC>" kak-command-map
    "<RET>" 'undefined
    "<BS>" 'undefined
    "<TAB>" 'undefined
    "<DEL>" ctl-x-map)
  :group 'kakoune-modes)

(define-minor-mode kak-insert-mode
  "Kakoune Insert Mode"
  :lighter " insert"
  :keymap (define-keymap
	    "ESC" #'kak-exit-insert
	    "S-<return>" #'kak-exit-insert)
  :group 'kakoune-modes)

(add-hook 'kak-normal-mode-hook #'(lambda () (setq global-mode-string "normal")))
(add-hook 'kak-insert-mode-hook #'(lambda () (setq global-mode-string "insert")))

(add-hook 'text-mode-hook 'kak-normal-mode)
(add-hook 'prog-mode-hook 'kak-normal-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'conf-mode-hook 'kak-normal-mode)
(add-hook 'conf-mode-hook 'display-line-numbers-mode)

(setq-default display-line-numbers-type 'relative)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)

(setq visible-bell t
      scroll-preserve-screen-position t
      backup-directory-alist '(("." . "~/.emacs-saves/"))
      auto-save-file-name-transforms '((".*" "~/.emacs-saves/" t)))

(set-face-attribute 'default nil :font "SauceCodePro Nerd Font" :height 110)

(display-battery-mode 1)
(display-time-mode 1)

;;(global-set-key (kbd "<escape>") 'keyboard-quit)
(keymap-global-set "M-RET" kak-command-map)

;; *** lang specific configuration ***
;; js
(setq js-indent-width 2)
