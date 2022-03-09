object WINService: TWINService
  OldCreateOrder = False
  DisplayName = 'MVCWebService'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
