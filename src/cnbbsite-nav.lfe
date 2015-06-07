(defmodule cnbbsite-nav
  (export all))

(include-lib "yaws/include/yaws_api.hrl")
(include-lib "exemplar/include/html-macros.lfe")

;;; Menus

(defun top-nav ()
  (top-menu-group (cnbb-data:top-nav)))

(defun side-nav
  (((match-arg server_path path))
   (logjam:debug (MODULE) 'side-nav/1 "pathinfo: ~p" `(,path))
    (side-nav-group
      (update-links
        (cnbb-data:side-nav)
        path))))

(defun bottom-nav ()
  (bottom-menu-group (cnbb-data:bottom-nav)))

;;; Top nav functions

(defun top-menu-group (links)
  (nav '(class "navbar navbar-top" role "navigation")
    (div '(class "container")
      (div '(class "navbar-header")
        (list
          (get-logo)
          (div '(class "collapse navbar-collapse navbar-ex1-collapse")
            (ul '(class "nav navbar-nav navbar-right")
                (lists:map #'top-menu-item/1 links))))))))

(defun top-menu-item
  ((`(,name ,path))
   (li (a `(href ,path) name))))

(defun get-logo ()
  (img '(src "/images/logo-1.6-long-3-x50.png"
         class "navlogo")))

;;; Side nav functions

(defun side-nav-group (sections)
  (div '(class "panel-group" role "tablist")
       (lists:map #'side-nav-section/1 sections)))

(defun side-nav-section
  ((`(#(group-name ,name) #(links ,items)))
   (let ((collapse-state (get-collapse-state items))
         (collapse-in (get-collapse-in items))
         (aria-expanded (get-aria-expanded items))
         (collapse-height (get-collapse-height items))
         (links (lists:map #'side-nav-item/1 items)))
     (logjam:debug (MODULE)
                   'side-nav-section
                   "Collapse state: ~p"
                   `(,collapse-state))
     (logjam:debug (MODULE)
                   'side-nav-section
                   "Links: ~p"
                   `(,links))
     (div '(class "panel panel-default")
          (list
           (div `(class "panel-heading"
                  role "tab"
                  id ,(++ name "GroupHeading"))
                (h4 `(class ,(++ "panel-title " name)
                      id "-collapsible-list-group-")
                    (a `(class ,collapse-state
                         data-toggle "collapse"
                         href ,(++ "#" name "Group")
                         aria-expanded "false"
                         aria-controls ,(++ name "Group"))
                       name)))
           (div `(id ,(++ name "Group")
                  class ,(++ "panel-collapse collapse" collapse-in)
                  role "tabpanel"
                  aria-labelledby ,(++ name "GroupHeading")
                  aria-expanded ,aria-expanded
                  ,@collapse-height)
                (ul '(class "list-group") links)))))))

(defun side-nav-item
  ((`#(,name ,path ,active?))
   (li `(class ,(++ "list-group-item" (highlight active?)))
       (a `(href ,path) name))))

(defun update-links (items path)
  items)

(defun highlight (active)
  (if active
    " active"
    ""))

(defun get-collapse-state (items)
  (if (has-active? items)
    ""
    " collapsed"))

(defun get-collapse-in (items)
  (if (has-active? items)
    " in"
    ""))

(defun get-aria-expanded (items)
  (if (has-active? items)
    "true"
    "false"))

(defun get-collapse-height (items)
  (if (has-active? items)
    '()
    '(style "height: 0px;")))

(defun has-active?
  (('undefined)
   'false)
  (('())
   'false)
  ((items) (when (is_list items))
   (logjam:debug (MODULE) 'has-active? "Items: ~p" `(,items))
   (lists:keymember 'true 3 items))
  ((_)
   'false))

;;; Bottom nav functions

(defun bottom-menu-group (items)
  (div '(class "bottom-nav")
    (string:join
      (lists:map #'bottom-menu-item/1 items)
      "&nbsp;|&nbsp;")))

(defun bottom-menu-item
  ((`(,name ,path))
   (a `(href ,path) name)))

