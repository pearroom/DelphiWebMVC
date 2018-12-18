object WM: TWM
  OldCreateOrder = False
  Actions = <>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 230
  Width = 415
  object WebFile: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/html'
        Extensions = 'html;htm'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpeg;jpg'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'image/x-icon'
        Extensions = 'ico'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end
      item
        MimeType = 'text/xml'
        Extensions = 'xml'
      end
      item
        MimeType = 'image/svg+xml'
        Extensions = 'svg'
      end
      item
        MimeType = 'application/font-woff'
        Extensions = 'woff '
      end
      item
        MimeType = 'application/font-woff'
        Extensions = 'woff2 '
      end
      item
        MimeType = 'text/richtext'
        Extensions = 'rtx'
      end
      item
        MimeType = 'application/x-zip-compressed'
        Extensions = 'zip'
      end
      item
        MimeType = 'text/plain'
        Extensions = 'txt'
      end
      item
      end>
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 184
    Top = 60
  end
end
