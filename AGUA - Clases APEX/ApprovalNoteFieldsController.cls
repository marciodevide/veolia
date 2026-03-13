public class ApprovalNoteFieldsController {

    @auraEnabled
    public static Opportunity getNoteFiledsOpp(Id oppId) {
        Opportunity opp = [
            SELECT Id,Name,OPO_TXT_Codigo_Oportunidad__c,Probability,Nombre__c,OPO_SEL_Territorio_Oportunidad__c,OPO_SEL_Canal_Entrada__c,
            COM_SEL_Oportunidad_Mono_Multi__c,COM_For_Producto_Lider__c,OPO_FOR_Departamento_Producto__c, OPO_FOR_Sub_mbito_Del_Producto_L_der__c,
            OPO_PKL_Origen_contrato__c,OPO_MPK_Servicios_concesion__c,
            Gestor_Actual__r.Name,OPO_LKP_Sociedad_Ofertante__r.Name,OPO_TXT_UTE_Name__c,
            OPO_PER_Participacion1__c,OPO_LKP_Empresa1__r.Name,OPO_PER_Participacion2__c,
            OPO_LKP_Empresa2__r.Name,OPO_PER_Participacion3__c,OPO_LKP_Empresa3__r.Name,
            OPO_PER_Participacion4__c,OPO_LKP_Empresa4__r.Name,OPO_SEL_Condicion_Pago__c,
            OPO_SEL_Via_Pago__c,OPO_TXT_Competencia__c,COM_SEL_estrategia__c,
            COM_DATE_limite_de_aprobacion_N_A__c,COM_DATE_Limite_entrega_N_A__c,
            CloseDate,OPO_DAT_Fecha_Inicio_Proyecto__c,OPO_DAT_Fecha_Fin_Proyecto__c,
            OPO_FOR_Meses_Duracion_Proyecto__c,OPO_NUM_Posible_Prroroga_Meses__c,
            OPO_SEL_Cualificacion__c,
            OPO_SEL_Estado_Proceso__c,OPO_SEL_Motivo_No_Necesaria__c,
            OPO_LKP_Gerente_Cuenta__r.Name,COM_LKP_Lider_oferta__r.Name,
            OPO_TXT_Principal_Subcontratacion__c,OPO_TXT_Alcance__c,
            OPO_TXT_Criterios_Decision__c,CurrencyIsoCode,OPO_NUM_Presupuesto_Licitacion__c,
            OPO_NUM_Importe_total_ofertado__c,OPO_CUR_Volumen_Total__c,
            OPO_FOR_Margen_Bruto_PER__c,OPO_NUM_Margen_Bruto__c,
            OPO_PER_Reduccion_del_presupuesto__c,OPO_BOL_OK_Lider__c,
            OPO_LKP_Tecnico_ECOFIN__r.Name,OPO_TXT_Contexto_Cliente__c,
            OPO_TXT_Criterios_Adicionales__c,OPO_NUM_Desviacion__c,
            OPO_BOL_OK_ECOFIN__c,OPO_TXT_Analisis_del_socio__c, OPO_TXT_Riesgo__c, OPO_LKP_Tecnico_SSJJ__c,OPO_TXT_Garantia__c,
            OPO_TXT_Garantia_Definitiva__c,OPO_NUM_Penalizacion__c,OPO_TXT_Temeridad__c,
            OPO_TXT_Limite_Responsabilidad__c,OPO_TXT_Limite_Subcontratacion__c,
            OPO_TXT_Causas_Excepcionales_Resolucion__c,OPO_TXT_Tratamiento_Masivo__c,
            OPO_TXT_Subrogacion__c,OPO_LKP_Tecnico_SSJJ__r.Name,OPO_BOL_Tecnico_SSJJ__c,
            Aprobador_Delivery_Center__r.Name,OPO_LKP_Aprobador_DC_Territorio__r.Name,
            Aprobador_Business_Development__r.Name,OPO_LKP_Aprobador_Ecofin__r.Name,
            OPO_LKP_Aprobador_DC__r.Name,OPO_SEL_Aprobador_Negocio__r.Name,
            OPO_LKP_Aprobador_Dir_Gen_Agua_Cat__r.Name,OPO_LKP_Aprobador_Dir_Agua__r.Name,
            OPO_LKP_Aprobador_Iberia__r.Name,OPO_LKP_Aprobador_Alta__r.Name,
            OPO_SEL_Aprobador_Director_Mercado__r.Name,OPO_LKP_Aprobador_CFO__r.Name,
            OPO_LKP_Aprobador_CEO__r.Name,OPO_LKP_Aprobador_COMOP__r.Name,
            OPO_LKP_Aprobador_adicional__r.Name,Owner.Name 
            FROM Opportunity WHERE Id = :oppId LIMIT 1];

        return opp;
    }
}