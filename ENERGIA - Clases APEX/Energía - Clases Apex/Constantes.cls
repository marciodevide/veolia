public class Constantes 
{
    /**
    * Constantes de generación de códigos de oportunidad
    *
    **
    * - Constantes usadas a la hora de generar el código de la oportunidad según la filial correspondiente
    **/
    // Etiquetas de filial
    public static string TAG_VSL = 'VSL';
    public static string TAG_VSC = 'VSC';
    public static string TAG_GIROA = 'NOR';
    public static String TAG_CONTRACTING = 'VCONTRACT';
    public static String TAG_VRM = 'VRM';
    public static String TAG_VP_LR = 'VP_LR';
    public static String TAG_VP_TP = 'VP_TP';
    public static String TAG_VSOL = 'VSOL';
    public static String TAG_ECOE = 'ECO';
    //JCD Oct 2025
    public static String TAG_GEO = 'GEO';

    // Claves de división de VSC: Cada división tiene su abreviatura correspondiente
    //SF00007 - ARU - En lugar de emplear valores en el código recuperamos la configuración mediante metadatos que pueden configurarse
    /*public static Map<String, String> MAPA_VSC_DIVISIONES = new Map<String, String>
    {
        'División Sanitario' => 'SAN',
        'División Industrial' => 'IND',
        'División Edificios' => 'EDI',
        'Delegación Norte' => 'NO',
        'Delegación Centro 1' => 'C1',
        'Delegación Centro 2'=> 'C2',
        'Delegación Sureste' => 'SE',
        'Delegación Canarias' => 'CA',
        'Delegación Suroeste' => 'SO',
        'Delegación Levante 1' => 'L1',
        'Delegación Levante 2' => 'L2',
        'EDEX' => 'EX',
        'Instalaciones' => 'INST'
    };*/
    public static Map<String, String> MAPA_VSC_DIVISIONES = recuperarDivisiones();
    // End SF00007

    /**
    * Tipos de registro
    **/
    /** Oportunidades **/
    
    /**SANDBOX**/
    /**   
    public static Id RT_OPP_VSL = '01224000000TaHC';
    public static Id RT_OPP_VSC = '01224000000TaHH';
    public static Id RT_OPP_GIROA = '01224000000TaHW';
    public static Id RT_OPP_CONTRACTING = '0120Q0000008e2m';
    **/
        
    /**PROD**/
    /*public static Id RT_OPP_VSL = '01224000000TaHC';
    public static Id RT_OPP_VSC = '01224000000TaHH';
    public static Id RT_OPP_GIROA = '01224000000TaHW';
    public static Id RT_OPP_CONTRACTING = '0121o000000kcDj';
    */
    //SF00007 - ARU - En lugar de emplear el Id de RecordType pasamos a emplear el DeveloperName
    public static String RT_OPP_VSL = 'VSL';
    public static String RT_OPP_VSC = 'VSC';
    public static String RT_OPP_GIROA = 'GIROA';
    public static String RT_OPP_CONTRACTING = 'VCONTRACT';
    public static String RT_OPP_VRM = 'VRM';
    public static String RT_OPP_VP_LR = 'VP_LR';
    public static String RT_OPP_VP_TP = 'VP_TP';
    public static String RT_OPP_VSOL = 'VSOL';
    public static String RT_OPP_ECOE = 'Ecoenergies';
    //JCD Oct 2025 Geotermia
    public static String RT_OPP_GEO = 'VGTRM';

    /**
    * Custom Settings - Nombres
    **/
    public static String CONTADOR_OPP_GIROA         = 'Opportunity.GIROA';
    public static String CONTADOR_OPP_VSL           = 'Opportunity.VSL';
    public static String CONTADOR_OPP_VSC           = 'Opportunity.VSC';
    public static String CONTADOR_OPP_CONTRACTING   = 'Opportunity.CONTRACTING';
    public static String CONTADOR_OPP_VRM           = 'Opportunity.VRM';
    public static String CONTADOR_OPP_VP_LR         = 'Opportunity.VP_LR';
    public static String CONTADOR_OPP_VP_TP         = 'Opportunity.VP_TP';
    public static String CONTADOR_OPP_VSOL          = 'Opportunity.VSOL';
    public static String CONTADOR_OPP_ECOE          = 'Opportunity.Ecoenergies';
    //JCD Oct 2025 Ya existia la CS.
    public static String CONTADOR_OPP_GEO          = 'Opportunity.VGTRM';

    //SF00007 - ARU - En lugar de emplear valores en el código recuperamos la configuración mediante metadatos que pueden configurarse
    public static Map<String, String> recuperarDivisiones(){

        Map<String, String> divisionesMap = new Map<String, String>();

        VL_Division_VSC__mdt[] divisiones = [SELECT MasterLabel, Codigo__c FROM VL_Division_VSC__mdt];

        for (VL_Division_VSC__mdt division : divisiones) {
            divisionesMap.put(division.MasterLabel, division.Codigo__c);
        }

        return divisionesMap;
    }
}