#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-----------+-------+----------------------+------+----------+¦¦
¦¦¦ Programa ¦ XCALCBH   ¦ Autor ¦ Josué Barbosa        ¦ Data ¦ 01/02/22 ¦¦¦
¦¦+----------+-----------+------ +----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Calculo de Banco de Horas Customizado                      ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Local                                                      ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function XCALCBH()

	Local   aArea   := GetArea()
	Local   aButtons := {{.F.,Nil},; // 1 - Copiar
	{.F.,Nil},; // 2 - Recortar
	{.F.,Nil},; // 3 - Colar
	{.F.,Nil},; // 4 - Calculadora
	{.F.,Nil},; // 5 - Spool
	{.F.,Nil},; // 6 - Imprimir
	{.F.,NIL},; // 7 - Confirma
	{.T.,"Fechar"},; // 8 - Cancelar
	{.F.,Nil},; // 9 - WalkTrhough
	{.F.,Nil},; // 10 - Ambiente
	{.F.,Nil},; // 11 - Mashup
	{.F.,Nil},; // 12 - Help
	{.F.,Nil},; // 13 - Formulário HTML
	{.F.,Nil}}  // 14 - ECM
	Private cTabFil := GetNextAlias()
	Private cTabRes := GetNextAlias()
	Private oTabFil
	Private oTabRes
	Private aCpoFil := {}
	Private aCpoRes := {}
	Private xSitua  := ""
	Private xCateg  := ""

	Public  INCLUI  := .T.

	oTabFil := FWTemporaryTable():New( cTabFil )
	oTabRes := FWTemporaryTable():New( cTabRes )

	//Criando a estrutura da tabela de Empresas
	aAdd(aCpoFil, {"FIL_FILIAL"   , "C", 06, 0} )
	aAdd(aCpoFil, {"FIL_MAT"      , "C", 13, 0} )
	aAdd(aCpoFil, {"FIL_MATPLA"   , "C", 250, 0} )
	aAdd(aCpoFil, {"FIL_CC"       , "C", 19, 0} )
	aAdd(aCpoFil, {"FIL_DTINI"    , "D", 08, 0} )
	aAdd(aCpoFil, {"FIL_DTFIM"    , "D", 08, 0} )
	aAdd(aCpoFil, {"FIL_SITFOL"   , "C", 5, 0} )
	aAdd(aCpoFil, {"FIL_CATFUN"   , "C", 12, 0} )
	//aAdd(aCpoFil, {"FIL_GERDES"   , "C", 1, 0} )
	aAdd(aCpoFil, {"FIL_DTBAIX"   , "D", 08, 0} )
	aAdd(aCpoFil, {"FIL_EMP"      , "C", 2, 0} )

	//Criando a estrutura da tabela de Preços
	aAdd(aCpoRes, {"RES_NOMFIL"   , "C", 50 , 0} )
	aAdd(aCpoRes, {"RES_MAT"      , "C", TamSx3("PB_MAT")[1], 0} )
	aAdd(aCpoRes, {"RES_NOME"     , "C", TamSx3("RA_NOME")[1], 0} )
	aAdd(aCpoRes, {"RES_PD"       , "C", TamSx3("PB_PD")[1], 0} )
	aAdd(aCpoRes, {"RES_DESCPD"   , "C", TamSx3("RV_DESC")[1], 0} )
	aAdd(aCpoRes, {"RES_HORAS"    , "N", TamSx3("PB_HORAS")[1], TamSx3("PB_HORAS")[2]} )
	aAdd(aCpoRes, {"RES_HRSCON"   , "N", TamSx3("PB_HORAS")[1], TamSx3("PB_HORAS")[2]} )
	aAdd(aCpoRes, {"RES_DATAPG"   , "D", TamSx3("PB_DATA")[1], 0} )
	aAdd(aCpoRes, {"RES_LOCAL"    , "C", TamSx3("RA_XMUNLOC")[1], 0} )
	aAdd(aCpoRes, {"RES_CC"       , "C", TamSx3("PB_CC")[1], 0} )
	aAdd(aCpoRes, {"RES_DESCCC"   , "C", TamSx3("CTT_DESC01")[1], 0} )
	aAdd(aCpoRes, {"RES_EMP"      , "C", 2, } )

	oTabFil:SetFields( aCpoFil )
	oTabFil:AddIndex("01", {"FIL_EMP"} )

	oTabRes:SetFields( aCpoRes )
	oTabRes:AddIndex("01", {"RES_NOMFIL","RES_MAT","RES_PD","RES_CC"} )

	//-----------------------------------------//
	//Criação das tabelas Temporárias          //
	//-----------------------------------------//

	oTabFil:Create()
	oTabRes:Create()

	FWExecView("-","XCALCBH",MODEL_OPERATION_INSERT,,{|| .T.},,,aButtons)

	RestArea(aArea)

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-----------+-------+----------------------+------+----------+¦¦
¦¦¦ Programa ¦ ModelDef  ¦ Autor ¦ Josué Barbosa        ¦ Data ¦ 10/02/20 ¦¦¦
¦¦+----------+-----------+------ +----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Funcao padrao MVC definicao de modelo de dados             ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Local                                                      ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function ModelDef()

	Local oStruFIL  := FWFormModelStruct():New()
	Local oStruRES  := FWFormModelStruct():New()

	oStruFIL:AddTable(cTabFil, {'FIL_EMP'}, "Filtros")
	oStruRES:AddTable(cTabRes, {"RES_NOMFIL","RES_MAT","RES_PD","RES_CC"}, "Resultado")

	//Adiciona os campos da estrutura
	// [01]  C   Titulo do campo
	// [02]  C   ToolTip do campo
	// [03]  C   Id do Field
	// [04]  C   Tipo do campo
	// [05]  N   Tamanho do campo
	// [06]  N   Decimal do campo
	// [07]  B   Code-block de validação do campo
	// [08]  B   Code-block de validação When do campo
	// [09]  A   Lista de valores permitido do campo
	// [10]  L   Indica se o campo tem preenchimento obrigatório
	// [11]  B   Code-block de inicializacao do campo
	// [12]  L   Indica se trata-se de um campo chave
	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	// [14]  L   Indica se o campo é virtual

	oStruFIL:AddField("Filial"             ,"","FIL_FILIAL"  ,"C",06,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Matricula"          ,"","FIL_MAT"     ,"C",13,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)
	oStruFIL:AddField("Matricula Planilha" ,"","FIL_MATPLA"  ,"C",250,0,Nil,Nil,{},.T.,,.F.,.F.,.F.)
	oStruFIL:AddField('Buscar','Buscar'    , 'GET'  , 'BT', 1, 0, /*{ |oMdl| GetArq(oMdl), .T. }*/, , {}, .F., , .F., .F., .F., , )
	oStruFIL:AddField("C. Custo"           ,"","FIL_CC"      ,"C",19,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Data Inicio"        ,"","FIL_DTINI"   ,"D",08,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Data Fim"           ,"","FIL_DTFIM"   ,"D",08,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Situações"          ,"","FIL_SITFOL"  ,"C",05,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Cat. Func."         ,"","FIL_CATFUN"  ,"C",12,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	//oStruFIL:AddField("Gera Desconto"      ,"","FIL_GERDES"  ,"C",01,0,Nil,Nil,{"S=Sim","N=Não"},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Data Baixa"         ,"","FIL_DTBAIX"  ,"D",08,0,Nil,Nil,{},.T.,,.T.,.F.,.F.)
	oStruFIL:AddField("Empresa"            ,"","FIL_EMP"     ,"C",02,0,Nil,Nil,{},.F.,,.T.,.F.,.F.)

	oStruRES:AddField("Filial"        ,"","RES_NOMFIL"  ,"C",50,0,Nil,Nil,{},.F.,,.T.,.T.,.F.)
	oStruRES:AddField("Matrícula"     ,"","RES_MAT"    ,"C",TamSx3("PB_MAT")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Nome"          ,"","RES_NOME"   ,"C",TamSx3("RA_NOME")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Verba"         ,"","RES_PD"     ,"C",TamSx3("PB_PD")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Desc. Verba"   ,"","RES_DESCPD" ,"C",TamSx3("RV_DESC")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Horas"         ,"","RES_HORAS"  ,"N",TamSx3("PB_HORAS")[1],TamSx3("PB_HORAS")[2],Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Horas Conv."   ,"","RES_HRSCON" ,"N",TamSx3("PB_HORAS")[1],TamSx3("PB_HORAS")[2],Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Data Pgto"     ,"","RES_DATAPG" ,"D",TamSx3("PB_DATA")[1],,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Localidade"    ,"","RES_LOCAL"  ,"C",TamSx3("RA_XMUNLOC")[1],,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("C. Custo"      ,"","RES_CC"     ,"C",TamSx3("PB_CC")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Descrição CC." ,"","RES_DESCCC" ,"C",TamSx3("CTT_DESC01")[1],0,Nil,Nil,{},.F.,,.F.,.T.,.F.)
	oStruRES:AddField("Empresa"       ,"","RES_EMP"    ,"C",02,0,Nil,Nil,{},.F.,,.F.,.T.,.F.)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('P_XCALCBH', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'FILMASTER', /*cOwner*/, oStruFIL, , /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( { "FIL_EMP" } )
	oModel:SetDescription( 'Calculo do Banco de Horas' )

	oModel:AddGrid( 'RESDETAIL', 'FILMASTER', oStruRES )
	oModel:SetRelation( 'RESDETAIL', {{'RES_EMP','FIL_EMP'}} , (cTabRes)->( IndexKey( 1 ) ) )
	oModel:GetModel( 'RESDETAIL' ):SetNoDeleteLine( .T. ) // permite apagar as linhas da grid
    oModel:GetModel( 'RESDETAIL' ):SetMaxLine(9999)

	oModel:GetModel( 'FILMASTER' ):SetDescription( 'Filtros' )
	oModel:GetModel( 'RESDETAIL' ):SetDescription( 'Resultado')

Return oModel



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-----------+-------+----------------------+------+----------+¦¦
¦¦¦ Programa ¦ ViewDef   ¦ Autor ¦                      ¦ Data ¦ 07/03/19 ¦¦¦
¦¦+----------+-----------+------ +----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Funcao padrao MVC definicao de view de dados               ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function ViewDef()

	Local oView
	Local oModel
	Local oStruFIL := FWFormViewStruct():New()
	Local oStruRES := FWFormViewStruct():New()

	//Adicionando campos da estrutura
	// [01]  C   Nome do Campo
	// [02]  C   Ordem
	// [03]  C   Titulo do campo
	// [04]  C   Descricao do campo
	// [05]  A   Array com Help
	// [06]  C   Tipo do campo
	// [07]  C   Picture
	// [08]  B   Bloco de PictTre Var
	// [09]  C   Consulta F3
	// [10]  L   Indica se o campo é alteravel
	// [11]  C   Pasta do campo
	// [12]  C   Agrupamento do campo
	// [13]  A   Lista de valores permitido do campo (Combo)
	// [14]  N   Tamanho maximo da maior opção do combo
	// [15]  C   Inicializador de Browse
	// [16]  L   Indica se o campo é virtual
	// [17]  C   Picture Variavel
	// [18]  L   Indica pulo de linha após o campo

	oStruFIL:AddField("FIL_FILIAL" ,"01","Filial?"          ,"Filial?"    ,Nil,"C","@!",Nil,"EMPMUL",.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_MAT"    ,"02","Matrícula?"       ,"Matrícula?" ,Nil,"C","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_MATPLA" ,"03","Planilha com as matrículas" ,"Plnailha com as matrículas" ,Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("GET"        ,'04',"Buscar","Buscar"  ,, "BT" ,,,,,,,,,,,, )
	oStruFIL:AddField("FIL_CC"     ,"05","Centro de Custo?" ,"Centro de Custo?",Nil,"C","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_DTINI"  ,"06","Data Inicio"      ,"Data inicio",Nil,"D","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_DTFIM"  ,"07","Data Fim"         ,"Data Fim"   ,Nil,"D","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_SITFOL" ,"08","Situações?"       ,"Situações?",Nil,"C","@!",Nil,"SX531_",.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_CATFUN" ,"09","Cat. Func.?"      ,"Cat. Func.?",Nil,"C","@!",Nil,"SX528_",.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	//oStruFIL:AddField("FIL_GERDES" ,"10","Gera desconto?"   ,"Gera desconto?",Nil,"C","@!",Nil,Nil,.T.,Nil,Nil,{"S=Sim","N=Não"},Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_DTBAIX" ,"10","Data da Baixa"    ,"Data da Baixa",Nil,"D","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruFIL:AddField("FIL_EMP"    ,"11","Empresa"          ,"Empresa",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)

	oStruRES:AddField("RES_NOMFIL"    ,"01","Filial","Filial",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_MAT"    ,"02","Matrícula","Matrícula",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_NOME"   ,"03","Nome","Nome",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_PD"     ,"04","Verba","Verba",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_DESCPD" ,"05","Derc. Verba","Derc. Verba",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_HORAS"  ,"06","Saldo","Saldo",Nil,"N",PesqPict("SPB","PB_HORAS"),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_HRSCON" ,"07","Saldo Conv.","Saldo Conv.",Nil,"N",PesqPict("SPB","PB_HORAS"),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_DATAPG" ,"08","Data pagamento","Data pagamento",Nil,"D",PesqPict("SPB","PB_DATA"),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_LOCAL"  ,"09","Localidade","Localidade",Nil,"C",PesqPict("SRA","RA_XMUNLOC"),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_CC"     ,"10","C. Custo","C. Custo",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_DESCCC" ,"11","Desc. CC","Desc. CC",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStruRES:AddField("RES_EMP"    ,"12","Empresa","Empresa",Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)

	oModel      := FWLoadModel( 'XCALCBH' )
	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )
	oModelRES 	:= oModel:GetModel( 'RESDETAIL' )

	oStruFIL:RemoveField( 'FIL_EMP' )
	oStruRES:RemoveField( 'RES_EMP' )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_FIL'	, oStruFIL, 'FILMASTER')
	oView:AddGrid( 'VIEW_RES'   , oStruRES, 'RESDETAIL')

	oView:CreateHorizontalBox( 'SUPERIOR' , 30 )
	oView:CreateHorizontalBox( 'INFERIOR' , 70 )

	oView:SetOwnerView( 'VIEW_FIL', 'SUPERIOR' 	)
	oView:SetOwnerView( 'VIEW_RES', 'INFERIOR' )

	oView:EnableTitleView('VIEW_FIL')
	oView:EnableTitleView('VIEW_RES')

	oView:SetFieldAction(  'GET'      ,   {  |oModel,  oView,  cCampo,  xContVar|  AtuCpo(oModel, oView, cCampo, xContVar, .F.)})
	oView:SetFieldAction(  'FIL_MAT'  ,   {  |oModel,  oView,  cCampo,  xContVar|  LimpaCpo(oModel, oView, cCampo, xContVar, .F.)})

	oView:SetViewProperty( 'VIEW_RES' , 'ENABLENEWGRID' )
	oView:SetViewProperty( 'VIEW_RES', "GRIDNOORDER")
	oView:SetViewProperty( 'VIEW_RES', "GRIDFILTER", {.T.})
	oView:SetViewProperty( 'VIEW_RES', "GRIDSEEK", {.T.})

	oView:AddUserButton("Calcular","CALC",{|| Processa( {|| Calcular() }, "Calculo", "realizando cálculo, aguarde...", .f.)})
	oView:AddUserButton("Exportar p/ Excel","ENVEXCEL",{|| Processa( {|| Exportar() }, "Exportar", "Realizando exportação dos calculos apurados, aguarde...", .f.)})
	oView:AddUserButton("Enviar para Resultados","ENVRESUL",{|| Processa( {|| EnvResult() }, "Resultado", "Realizando Baixa do Banco de horas, aguarde...", .f.)})

Return( oView )

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-----------+-------+----------------------+------+----------+¦¦
¦¦¦ Programa ¦ AtuCpo    ¦ Autor ¦ Josué Barbosa        ¦ Data ¦ 23/09/21 ¦¦¦
¦¦+----------+-----------+------ +----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Dispara os gatilhos criados para os campos da tabela tem-  ¦¦¦
¦¦¦          ¦ poraria                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function AtuCpo(oModel, oView, cCampo, xContVar, lAuto )

	Local cArq := cGetFile("Arquivo Excel ( *.CSV ) |*.CSV|", "Selecione a Planilha com as matriculas.",,,.T., GETF_LOCALHARD )

	oView  := FWViewActive()
	oModel := FWModelActive()

	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )

	If !Empty(cArq)
		oModelFIL:LoadValue("FIL_MATPLA",cArq)
		oModelFIL:LoadValue("FIL_MAT","")
	EndIf

	oView:Refresh()

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+-----------+-------+----------------------+------+----------+¦¦
¦¦¦ Programa ¦ LimpaCpo  ¦ Autor ¦ Josué Barbosa        ¦ Data ¦ 03/02/22 ¦¦¦
¦¦+----------+-----------+------ +----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Dispara os gatilhos criados para os campos da tabela tem-  ¦¦¦
¦¦¦          ¦ poraria                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Static Function LimpaCpo(oModel, oView, cCampo, xContVar, lAuto )

	oView  := FWViewActive()
	oModel := FWModelActive()

	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )

	If !Empty(xContVar)
		oModelFIL:LoadValue("FIL_MATPLA","")
	EndIf

	oView:Refresh()

Return

User Function FilSitua()

	Private nTam      := 0
	Private aCat      := {}
	Private MvRet     := Alltrim(ReadVar())
	Private MvPar     := &(Alltrim(ReadVar()))
	Private cTitulo   := ""
	Private MvParDef  := ""

	//Tratamento para carregar variaveis da lista de opcoes
	nTam:= 5

	cTitulo := "Situações"

	SX5->(DbSetOrder(1))
	SX5->(DbSeek(XFilial("SX5")+"31"))
	While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "31"
		MvParDef += AllTrim(SX5->X5_CHAVE)
		aAdd(aCat,AllTrim(SX5->X5_CHAVE)+" - "+AllTrim(SX5->X5_DESCRI))

		SX5->(DbSkip())
	End

	//Executa funcao que monta tela de opcoes
	f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F./*,nTam,1,.F.*/)

	&MvRet := PADR(MvPar,nTam)

	//Guarda numa variavel private o retorno da função
	xSitua := &MvRet

Return(.T.)

User Function FilCateg()

	Private nTam      := 0
	Private aCat      := {}
	Private MvRet     := Alltrim(ReadVar())
	Private MvPar     := &(Alltrim(ReadVar()))
	Private cTitulo   := ""
	Private MvParDef  := ""

	//Tratamento para carregar variaveis da lista de opcoes
	nTam:= 12

	cTitulo := "Categorias"

	SX5->(DbSetOrder(1))
	SX5->(DbSeek(XFilial("SX5")+"28"))
	While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "28"

		If !AllTrim(SX5->X5_CHAVE) $ "0#1#2#3#4#5#6#7#8#9"
			MvParDef += AllTrim(SX5->X5_CHAVE)
			aAdd(aCat,AllTrim(SX5->X5_CHAVE)+" - "+AllTrim(SX5->X5_DESCRI))
		Endif

		SX5->(DbSkip())
	End

	//Executa funcao que monta tela de opcoes
	f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F./*,nTam,1,.F.*/)

	&MvRet := PADR(MvPar,nTam)

	//Guarda numa variavel private o retorno da função
	xCateg := &MvRet

Return(.T.)

Static Function Calcular()

	Local cTabQry  := GetNextAlias()
    Local lProx    := .F.

	oView  := FWViewActive()
	oModel := FWModelActive()

	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )
	oModelRES 	:= oModel:GetModel( 'RESDETAIL' )

	//----------------------------------------------------//
	// Validações dos campos de preenchimento obrigatório //
	//----------------------------------------------------//

	If Empty(oModelFIL:GetValue("FIL_FILIAL"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Filial' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Filial' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_MAT")) .AND. Empty(oModelFIL:GetValue("FIL_MATPLA"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Matrícula não informada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Matricula' ou o campo 'Planilha com as matrículas' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_CC"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Centro de Custo' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Centro de Custo' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_DTINI"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Data Inicio' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Data inicio' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_DTFIM"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Data Fim' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Data Fim' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_SITFOL"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Situações' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Situações' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_CATFUN"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Cat. Func.' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Cat. Func.' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	If Empty(oModelFIL:GetValue("FIL_DTBAIX"))
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "Campo 'Data da Baixa' não informado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor preencher o campo 'Data da Baixa' para que seja possível prosseguir com o cálculo!"})
		Return
	Endif

	xFil     := oModelFIL:GetValue("FIL_FILIAL")

	If !Empty(oModelFIL:GetValue("FIL_MAT"))
		xFiltMat := ConvCpo("FIL_MAT",Alltrim(oModelFIL:GetValue("FIL_MAT")))
	Else
		xFiltMat := ConvCpo("FIL_MATPLA",Alltrim(oModelFIL:GetValue("FIL_MATPLA")))
	Endif

	xFiltCC := ConvCpo("FIL_CC",Alltrim(oModelFIL:GetValue("FIL_CC")))
	xDtIni  := oModelFIL:GetValue("FIL_DTINI")
	xDtFim  := oModelFIL:GetValue("FIL_DTFIM")
	xFilSit := ConvCpo("FIL_SITFOL",oModelFIL:GetValue("FIL_SITFOL"))
	xFilCat := ConvCpo("FIL_CATFUN",Alltrim(oModelFIL:GetValue("FIL_CATFUN")))

	oModelRES:ClearData(.F.,.T.) // Limpa Grid com os itens calculados anteriormente

	cQuery := " SELECT PI_FILIAL AS FILIAL,							 "
	cQuery += "        RA_MAT AS MATRICULA,							 "
	cQuery += "        RA_NOME AS NOME,								 "
	cQuery += "        PI_CC AS CCUSTO,								 "
	cQuery += "        RA_XMUNLOC AS LOCALIDADE,				     "
	cQuery += "        CTT_DESC01 AS DESC_CC,						 "
	cQuery += "        PI_DATA AS DATA_BH,							 "
	cQuery += "        PI_PD AS EVENTO,								 "
	cQuery += "        PI_QUANT AS HORAS							 "
	cQuery += " FROM "+RetSqlName("SPI")+" SPI						 "
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" SRA ON (RA_FILIAL = PI_FILIAL		 "
	cQuery += "                           AND RA_MAT = PI_MAT		 "
	cQuery += "                           AND SRA.D_E_L_E_T_ <> '*') "
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT ON (CTT_CUSTO = PI_CC			 "
	cQuery += "                           AND CTT.D_E_L_E_T_ <> '*') "
	cQuery += " WHERE SPI.D_E_L_E_T_ <> '*'							 "
	cQuery += "   AND PI_STATUS <> 'B'								 "
	cQuery += "   AND PI_DTBAIX = ' '								 "
	cQuery += "   AND PI_DATA BETWEEN '"+DTOS(xDtIni)+"' AND '"+DTOS(xDtFim)+"'  "

	If Alltrim(xFil) <> '*'
		cQuery += "   AND PI_FILIAL = '"+Alltrim(xFil)+"'			 "
	Endif

	If !Empty(xFiltMat)
		cQuery += xFiltMat
	Endif

	If !Empty(xFiltCC)
		cQuery += xFiltCC
	Endif

	cQuery += xFilSit
	cQuery += xFilCat
	cQuery += " ORDER BY PI_FILIAL,									 "
	cQuery += "          PI_MAT,									 "
	cQuery += "          PI_DATA									 "

	oState := FWPreparedStatement():New()
	oState:SetQuery(cQuery)

	MPSysOpenQuery(cQuery,cTabQry)
	oState:Destroy()

	nTot := Contar(cTabQry,"!Eof()")

	Procregua(nTot)

	(cTabQry)->(DbGoTop())

	While (cTabQry)->(!EOF())

		IncProc("Processando Matrícula: "+(cTabQry)->MATRICULA+" - "+Alltrim((cTabQry)->NOME))

		xFilAnt  := (cTabQry)->FILIAL
		xMatAnt  := (cTabQry)->MATRICULA
		xNomAnt  := (cTabQry)->NOME
		xCCAnt   := (cTabQry)->CCUSTO
		xDescCC  := (cTabQry)->DESC_CC
		xLocal   := (cTabQry)->LOCALIDADE
		xTpEven  := ""
		nSaldo   := 0
		xVerba   := Posicione("SP9",2,(cTabQry)->FILIAL+"023A","P9_CODFOL")
		xVerbaD  := Posicione("SP9",2,(cTabQry)->FILIAL+"024A","P9_CODFOL")
		xDescVer := Posicione("SRV",1,xFilial("SRV")+xVerba,"RV_DESC")

		While (cTabQry)->FILIAL+(cTabQry)->MATRICULA == xFilAnt+xMatAnt .and. (cTabQry)->(!EOF())

			xTpEven := Posicione("SP9",1,(cTabQry)->FILIAL+(cTabQry)->EVENTO,"P9_TIPOCOD")

			If xTpEven $ "1*3"
				//nSaldo += fConvHr( (cTabQry)->HORAS , "D" )
				nSaldo := __TimeSum(nSaldo,(cTabQry)->HORAS)
			Else
				//nSaldo -= fConvHr( (cTabQry)->HORAS , "D" )
				nSaldo := __TimeSub( nSaldo,(cTabQry)->HORAS)
			Endif

			(cTabQry)->(DbSkip())
		End

		If lProx
			oModelRES:AddLine()
		Endif

		oModelRES:GoLine(oModelRES:Length())

		oModelRES:SetValue('RES_NOMFIL',xFilAnt+" - "+Alltrim(FWFilialName(cEmpAnt,xFilAnt)))
		oModelRES:SetValue('RES_MAT'   ,xMatAnt)
		oModelRES:SetValue('RES_NOME'  ,xNomAnt)
		oModelRES:SetValue('RES_PD'    ,xVerba)
		oModelRES:SetValue('RES_DESCPD',Alltrim(xDescVer))
		oModelRES:SetValue('RES_HORAS'  ,nSaldo)

		If nSaldo < 0
			oModelRES:SetValue('RES_HRSCON' , (fConvHr( (nSaldo * (-1)) , "D" ) * -1))
		Else
			oModelRES:SetValue('RES_HRSCON' ,fConvHr( nSaldo , "D" ))
		Endif

		oModelRES:SetValue('RES_LOCAL'  ,xLocal)
		oModelRES:SetValue('RES_DATAPG',oModelFIL:GetValue("FIL_DTBAIX"))
		oModelRES:SetValue('RES_CC'    ,xCCAnt)
		oModelRES:SetValue('RES_DESCCC',xDescCC)
        lProx := .T.

		loop

	End

	(cTabQry)->(DbCloseArea())

	oModelRES:GoLine(1)
	oView:Refresh()

Return

Static Function EnvResult()

	Local nY := 0
	Local lBaixa
	Local cArq       := ""
	Local cWorkSheet := ""
	Local cTable     := ""
	Local oFwMsEx    := Nil
	Local cCaminho   := "C:\Exportação BH\"

	oView  := FWViewActive()
	oModel := FWModelActive()

	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )
	oModelRES 	:= oModel:GetModel( 'RESDETAIL' )

	If oModelRES:Length() = 0
		Help(NIL, NIL, "ATENÇÃO!!!", NIL, "O Calculo não foi realizado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor realizar o calculo para que seja possível prosseguir com a baixa do Banco de Horas!"})
		Return
	Endif

	If oModelRES:Length() = 1
		oModelRES:GoLine(1)
		If Empty(oModelRES:GetValue("RES_NOMFIL") )
			Help(NIL, NIL, "ATENÇÃO!!!", NIL, "O Calculo não foi realizado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor realizar o calculo para que seja possível prosseguir com a baixa do Banco de Horas!"})
			Return
		Endif
	Endif

	If !MsgYesNo("Deseja prosseguir com a baixa do Banco de Horas?","Atenção!")
		Return
	Endif

	oFwMsEx := FWMsExcelEx():New()

	cWorkSheet := "Resultado"
	cTable     := "LOG - FECHAMENTO DE BANCO DE HORAS ("+DTOC(Date())+" - "+Time()+") "

	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	oFwMsEx:AddColumn( cWorkSheet, cTable , "Filial"           , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Matrícula"        , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Nome"             , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Verba"            , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Desc Verba"       , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Saldo"            , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Saldo Convertido" , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Data Inicial"     , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Data Final"       , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Data Fechamento"  , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Localidade"       , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Centro de Custo"  , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Desc. CC"         , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Status"           , 1,1)

	ProcRegua(oModelRES:Length())

	SPB->(DbSetOrder(1))

	For nY := 1 To oModelRES:Length()

		oModelRES:GoLine(nY)

		IncProc("Processando matrícula: "+oModelRES:GetValue("RES_MAT")+" - "+oModelRES:GetValue("RES_NOME"))

		xFil   := Left(oModelRES:GetValue("RES_NOMFIL"),6)
		xMat   := oModelRES:GetValue("RES_MAT")
		xPd    := oModelRES:GetValue("RES_PD")
		xCC    := oModelRES:GetValue("RES_CC")
		xDtIni := oModelFIL:GetValue("FIL_DTINI")
		xDtFim := oModelFIL:GetValue("FIL_DTFIM")
		xData  := oModelRES:GetValue("RES_DATAPG")
		xSaldo := oModelRES:GetValue("RES_HRSCON")

		lBaixa := BaixaBH(xFil,xMat,xDtIni,xDtFim,xData)

		If xSaldo <= 0
			lBaixa := .F.

			oFwMsEx:AddRow( cWorkSheet, cTable,{oModelRES:GetValue("RES_NOMFIL"),; // Filial
			oModelRES:GetValue("RES_MAT"),;  // Matrícula
			oModelRES:GetValue("RES_NOME"),; // Nome
			oModelRES:GetValue("RES_PD"),;   // Verba
			oModelRES:GetValue("RES_DESCPD"),; // Descrição da Verba
			cValToChar(oModelRES:GetValue("RES_HORAS")),;  // Horas
			cValToChar(oModelRES:GetValue("RES_HRSCON")),; // Horas Convertidas
			DTOC(xDtIni),; // Data Inicio
			DTOC(xDtFim),; // Data Final
			DTOC(oModelRES:GetValue("RES_DATAPG")),; // Data de Fechamento
			oModelRES:GetValue("RES_LOCAL"),; // Localidade
			oModelRES:GetValue("RES_CC"),;     // Centro de Custo
			oModelRES:GetValue("RES_DESCCC"),; // Desc. CC
			"A baixa do banco de horas foi realizada, porém não foram enviados eventos para resultados. Funcionário possui horas negativas!"})

		Endif

		If lBaixa

			IF SPB->(MsSeek(xFil+xMat+xPd+xCC))
				RecLock("SPB",.F.)
			Else
				RecLock("SPB",.T.)
			Endif

			SPB->PB_FILIAL := xFil
			SPB->PB_MAT    := xMat
			SPB->PB_PD     := xPd
			SPB->PB_TIPO1  := "H"
			SPB->PB_HORAS  := xSaldo
			SPB->PB_DATA   := xData
			SPB->PB_CC     := xCC
			SPB->PB_TIPO2  := "G"
			SPB->(MsUnLock())

			oFwMsEx:AddRow( cWorkSheet, cTable,{oModelRES:GetValue("RES_NOMFIL"),; // Filial
			oModelRES:GetValue("RES_MAT"),;  // Matrícula
			oModelRES:GetValue("RES_NOME"),; // Nome
			oModelRES:GetValue("RES_PD"),;   // Verba
			oModelRES:GetValue("RES_DESCPD"),; // Descrição da Verba
			cValToChar(oModelRES:GetValue("RES_HORAS")),;  // Horas
			cValToChar(oModelRES:GetValue("RES_HRSCON")),; // Horas Convertidas
			DTOC(xDtIni),; // Data Inicio
			DTOC(xDtFim),; // Data Final
			DTOC(oModelRES:GetValue("RES_DATAPG")),; // Data de Fechamento
			oModelRES:GetValue("RES_LOCAL"),;  // Localidade
			oModelRES:GetValue("RES_CC"),;     // Centro de Custo
			oModelRES:GetValue("RES_DESCCC"),; // Desc. CC
			"A baixa do banco de horas foi realizada com sucesso! O evento foi enviado para resultados."})

		Else

			If xSaldo > 0
				oFwMsEx:AddRow( cWorkSheet, cTable,{oModelRES:GetValue("RES_NOMFIL"),; // Filial
				oModelRES:GetValue("RES_MAT"),;  // Matrícula
				oModelRES:GetValue("RES_NOME"),; // Nome
				oModelRES:GetValue("RES_PD"),;   // Verba
				oModelRES:GetValue("RES_DESCPD"),; // Descrição da Verba
				cValToChar(oModelRES:GetValue("RES_HORAS")),;  // Horas
				cValToChar(oModelRES:GetValue("RES_HRSCON")),; // Horas Convertidas
				DTOC(xDtIni),; // Data Inicio
				DTOC(xDtFim),; // Data Final
				DTOC(oModelRES:GetValue("RES_DATAPG")),; // Data de Fechamento
				oModelRES:GetValue("RES_LOCAL"),;  // Localidade
				oModelRES:GetValue("RES_CC"),;     // Centro de Custo
				oModelRES:GetValue("RES_DESCCC"),; // Desc. CC
				"A baixa do banco de horas não foi realizada! Favor entrar em contato com o setor de TI via chamado."})
			Endif
		Endif

	Next nY

	oFwMsEx:Activate()

	cArq := "FECHAMENTO_BH_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".xml"

	MsgRun( "Gerando o arquivo, aguarde...", "Fechamento de Banco de Horas", {|| oFwMsEx:GetXMLFile( cArq ) } )

	If !ExistDir( cCaminho )
		MakeDir( cCaminho)
	Endif

	If __CopyFile( cArq, cCaminho + cArq )

		If !ApOleClient("MSExcel")
			MsgAlert("Microsoft Excel não instalado!")
		Else
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cCaminho + cArq )
			oExcelApp:SetVisible(.T.)
		EndIF

		//FERASE(cDirTmp+cArq)

	Else
		MsgInfo( "Arquivo não copiado para temporário do usuário." )
	Endif

	MsgInfo("Processo Finalizado com Sucesso!")

	oModelRES:GoLine(1)
	oView:Refresh()

Return

Static Function ConvCpo(_cCampo,_cConteudo)

	Local cRet := ""
	Local nX

	If _cCampo == "FIL_MAT"
		If _cConteudo <> "*"
			If "-" $ _cConteudo
				If Len(_cConteudo) = 13
					cRet := " AND PI_MAT BETWEEN '"+Left(_cConteudo,6)+"' AND '"+Right(_cConteudo,6)+"' "
				Endif
			Else
				cRet := " AND PI_MAT = '"+_cConteudo+"' "
			Endif
		Endif
	ElseIf _cCampo == "FIL_MATPLA"

		If File(_cConteudo)
			nHandle := FT_FUse(_cConteudo) // Abre o arquivo e salva o Handle nessa propriedade.

			If nHandle == -1 // Se problema na leitura do arquivo
				MsgAlert('Problemas na Leitura do arquivo, favor verificar se o caminho esta correto ou o arquivo não esta aberto em outro processo.','Atencao!')
			Else

				FT_FGoTop() // vai para primeira linha do registro

				nCont := 1 // Inicializa Contador

				ProcRegua(1)

				cRet := " AND PI_MAT IN ( '"

				While !FT_FEOF()

					IncProc("Lendo linhas da Planilha com as matrículas..."+Alltrim(Str(nCont)))

					If nCont = 1 //Pula o Cabeçalho
						nCont++
						FT_FSKIP()
						loop
					End

					cLinha  := AllTrim(FT_FReadLn()) // Retorna a linha corrente

					If ";;" $ cLinha .OR. Empty(cLinha)
						FT_FSKIP()
						loop
					Endif


					aLinha  := StrToKarr(cLinha,";")

					If nCont > 2
						cRet += ",'"
					Endif

					cRet += StrZero(Val(aLinha[1]),6)+"'"

					nCont++

					FT_FSKIP()

				End

				// Fecha o Arquivo
				FT_FUSE()

				cRet += ") "
			EndIf

		Else
			MsgAlert("Não foi possível abrir a planilha informada no campo 'Planilha com as matrículas'!")
		EndIf
	ElseIf _cCampo == "FIL_CC"
		If _cConteudo <> "*"
			If "-" $ _cConteudo
				If Len(_cConteudo) = 13
					cRet := " AND PI_CC BETWEEN '"+Left(_cConteudo,6)+"' AND '"+Right(_cConteudo,6)+"' "
				Endif
			Else
				cRet := " AND PI_CC = '"+_cConteudo+"' "
			Endif
		Endif
	ElseIf _cCampo == "FIL_SITFOL"
		cRet += " AND RA_SITFOLH IN ('"

		For nX := 1 To Len(_cConteudo)
			If Substr(_cConteudo,nX,1) <> "*"
				If nX > 1
					cRet += ",'"
				Endif
				cRet += Substr(_cConteudo,nX,1)+"'"
			Endif
		Next nX

		cRet += ") "
	ElseIf _cCampo == "FIL_CATFUN"
		cRet += " AND RA_CATFUNC IN ('"

		For nX := 1 To Len(_cConteudo)
			If Substr(_cConteudo,nX,1) <> "*"
				If nX > 1
					cRet += ",'"
				Endif
				cRet += Substr(_cConteudo,nX,1)+"'"
			Endif
		Next nX

		cRet += ") "

	Endif

Return (cRet)

Static Function BaixaBH(_cFil,_cMat,_xDataIni,_xDataFim,_xDtBaixa)

	Local cQuery := ""
	Local lOk    := .T.

	cQuery += " UPDATE "+RetSqlName("SPI")
	cQuery += " SET PI_STATUS = 'B', PI_DTBAIX = '"+DTOS(_xDtBaixa)+"' "
	cQuery += " WHERE PI_FILIAL = '"+_cFil+"' "
	cQuery += " AND   PI_DATA BETWEEN '"+DTOS(_xDataIni)+"' AND '"+DTOS(_xDataFim)+"' "
	cQuery += " AND   PI_STATUS <> 'B'     "
	cQuery += " AND   PI_MAT = '"+_cMat+"' "
	cQuery += " AND   D_E_L_E_T_ <> '*'    "

	If TCSqlExec(cQuery) < 0
		lOk := .F.
	Else
		TCSqlExec("commit")
	Endif

Return (lOk)

Static Function Exportar()

	Local y
	Private cArq       := ""
	Private cWorkSheet := ""
	Private cTable     := ""
	Private oFwMsEx    := Nil
	Private cCaminho   := "C:\Exportação BH\"
	Private aRet       := {}
	Private aInfoPlan  := {}

	oView  := FWViewActive()
	oModel := FWModelActive()

	oModelFIL 	:= oModel:GetModel( 'FILMASTER' )
	oModelRES 	:= oModel:GetModel( 'RESDETAIL' )

	oFwMsEx := FWMsExcelEx():New()

	cWorkSheet := "Apuração"
	cTable     := "EXPORTAÇÃO DE SALDOS DE BANCO DE HORAS - ("+DTOC(Date())+" - "+Time()+") "

	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	oFwMsEx:AddColumn( cWorkSheet, cTable , "Filial"           , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Matrícula"        , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Nome"             , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Verba"            , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Desc Verba"       , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Saldo"            , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Saldo Convertido" , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Data pagamento"   , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Localidade"       , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Centro de Custo"  , 1,1)
	oFwMsEx:AddColumn( cWorkSheet, cTable , "Desc. CC"         , 1,1)

	ProcRegua(oModelRES:Length())

	For y:= 1 To oModelRES:Length()

		oModelRES:GoLine(y)

		IncProc("Processando matrícula: "+oModelRES:GetValue("RES_MAT")+" - "+oModelRES:GetValue("RES_NOME"))

		oFwMsEx:AddRow( cWorkSheet, cTable,{oModelRES:GetValue("RES_NOMFIL"),; // Filial
		oModelRES:GetValue("RES_MAT"),;  // Matrícula
		oModelRES:GetValue("RES_NOME"),; // Nome
		oModelRES:GetValue("RES_PD"),;   // Verba
		oModelRES:GetValue("RES_DESCPD"),; // Descrição da Verba
		cValToChar(oModelRES:GetValue("RES_HORAS")),;  // Horas
		cValToChar(oModelRES:GetValue("RES_HRSCON")),; // Horas Convertidas
		DTOC(oModelRES:GetValue("RES_DATAPG")),; // Data de Pagamento
		oModelRES:GetValue("RES_LOCAL"),;     // Localidade
		oModelRES:GetValue("RES_CC"),;     // Centro de Custo
		oModelRES:GetValue("RES_DESCCC")}) // Desc. CC

	Next y

    oModelRES:GoLine(1)
    oView:Refresh()

	oFwMsEx:Activate()

	cArq := "EXPORTACAO_BH_"+DTOS(Date())+"_"+StrTran(Time(),":","")+".xml"

	MsgRun( "Gerando o arquivo, aguarde...", "Calculo de Banco de Horas", {|| oFwMsEx:GetXMLFile( cArq ) } )

	If !ExistDir( cCaminho )
		MakeDir( cCaminho)
	Endif

	If __CopyFile( cArq, cCaminho + cArq )

		If !ApOleClient("MSExcel")
			MsgAlert("Microsoft Excel não instalado!")
		Else
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cCaminho + cArq )
			oExcelApp:SetVisible(.T.)
		EndIF

		//FERASE(cDirTmp+cArq)

	Else
		MsgInfo( "Arquivo não copiado para temporário do usuário." )
	Endif

Return()
