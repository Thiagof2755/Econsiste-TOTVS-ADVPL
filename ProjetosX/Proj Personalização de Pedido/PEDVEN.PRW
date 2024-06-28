
#Include "Protheus.ch"
#Include "TopConn.ch"


User Function PEDVEN()
	
    Local cUrl := "http://localhost:8080/index.html"
    HttpBrowse(cUrl)
Return
