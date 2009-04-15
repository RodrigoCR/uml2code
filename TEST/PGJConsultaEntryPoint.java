/*
 * PGJConsultaEntryPoint.java
 *
 * Created on 12 de enero de 2009, 19:18
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package mx.gob.df.ssp.client;


//import mx.gob.df.ssp.server.Conexion;
import com.google.gwt.user.client.ui.Widget;
import com.gwtext.client.core.Margins;
import com.gwtext.client.core.RegionPosition;
import com.gwtext.client.widgets.*;
import com.gwtext.client.widgets.layout.BorderLayout;
import com.gwtext.client.widgets.layout.BorderLayoutData;
import com.gwtext.client.widgets.layout.FitLayout;

import com.gwtext.client.core.EventObject;
import com.gwtext.client.core.Position;
import com.gwtext.client.widgets.Button;
import com.gwtext.client.widgets.event.ButtonListenerAdapter;
import com.gwtext.client.widgets.form.*;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;

import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.RadioButton;
import com.gwtext.client.data.Record;
import com.gwtext.client.data.SimpleStore;
import com.gwtext.client.data.Store;
import com.gwtext.client.widgets.Panel;
import com.gwtext.client.widgets.form.ComboBox;
import com.gwtext.client.widgets.form.FormPanel;
import com.gwtext.client.widgets.form.event.ComboBoxListenerAdapter;


import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.ServiceDefTarget;
import com.gwtext.client.core.SortDir;
import com.gwtext.client.data.ArrayReader;
import com.gwtext.client.data.FieldDef;
import com.gwtext.client.data.GroupingStore;
import com.gwtext.client.data.MemoryProxy;
import com.gwtext.client.data.RecordDef;
import com.gwtext.client.data.SortState;
import com.gwtext.client.data.StringFieldDef;
import com.gwtext.client.widgets.grid.ColumnConfig;
import com.gwtext.client.widgets.grid.ColumnModel;
import com.gwtext.client.widgets.grid.GridPanel;
import com.gwtext.client.widgets.grid.GroupingView;
import com.gwtext.client.widgets.layout.AnchorLayoutData;
import com.gwtext.client.widgets.layout.FormLayout;
import com.gwtext.client.widgets.layout.RowLayout;
import com.gwtext.client.widgets.layout.VerticalLayout;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author lander
 */
public class PGJConsultaEntryPoint implements EntryPoint {

    private TabPanel centerPanel = new TabPanel();
    private ComboBox comboRegion;
    private ComboBox comboDelegacion;
    private ComboBox comboSector;
    private DateField fechaDesde;
    private DateField fechaHasta;
    private DateField fechaUnica;
    private RadioButton radioConsultaUnica;
    private RadioButton radioConsultaRango;
//    private ComboBox horaConsultaUnica;
    private Panel panelEstadoDeFuerzaActual;
    Object[][] regiones = new Object[][]{new Object[]{"R1", "REGION I"}};
    Object[][] delegaciones = new Object[][]{new Object[]{"R1", "REGION I"}};
    Object[][] sectores = new Object[][]{new Object[]{"R1", "REGION I"}};
    List<Object[][]> catalogos = new ArrayList();
    private TextField claveSIPTextField;
    private TextField folioPuestoMandoTextField;
    private TextField avPreviaTextField;
    private TextField delitoTextField;
    BDServiceAsync bdServiceAsync = (BDServiceAsync) GWT.create(BDService.class);
    GridPanel grid;
    String[][] tablaResultado;
    boolean buscar;
    private Checkbox checkBoxHoraConsulta4a4;
    Store regionesStore;
    Store delegacionesStore;
    Store sectoresStore;
    FormPanel formPanel;
    FieldSet fieldSet;

    /**
     * Clase que implementa un listener para el RadioButton de Consulta Unica
     */
    class ConsultaUnicaListener implements ClickListener {

        public void onClick(Widget sender) {
            fechaUnica.enable();
//            horaConsultaUnica.enable();
            fechaDesde.disable();
            fechaHasta.disable();
        }
    }

    /**
     * Clase que implementa un listener para el RadioButton de Consulta por Rango de Fechas
     */
    class ConsultaRangoListener implements ClickListener {

        public void onClick(Widget sender) {
            fechaUnica.disable();
//            horaConsultaUnica.disable();
            fechaDesde.enable();
            fechaHasta.enable();
        }
    }

    /**
     * Clase que extiende al listener de botones e implementa la búsqueda
     */
    class BotonBuscarListener extends ButtonListenerAdapter {

        @Override
        public void onClick(Button button, EventObject e) {


            MessageBox.show(new MessageBoxConfig() {

                {
                    setMsg("Realizando Búsqueda");
                    setProgressText("Cargando...");
                    setWidth(300);
                    setWait(true);
                    setWaitConfig(new WaitConfig() {

                        {
                            setInterval(200);
                        }
                    });
                //setAnimEl(button.getId());
                }
            });


            System.out.println(">>>>> El bdService: " + bdServiceAsync + " >>>>>>>");

            ((ServiceDefTarget) bdServiceAsync).setServiceEntryPoint(GWT.getModuleBaseURL());

            final AsyncCallback callback = new AsyncCallback() {

                public void onSuccess(Object result) {
                    MessageBox.hide();
                    if (result == null) {
                        notificar("Resultado nulo");
                    } else {
                        if (buscar) {
                            tablaResultado = (String[][]) result;
                            notificar("Búsqueda realizada");

                            Panel centerPanelOne = new Panel();
                            VerticalLayout layout = new VerticalLayout(50);
                            centerPanelOne.setLayout(layout);

                            //centerPanelOne.setTitle(comboSector.getValue());
                            centerPanelOne.setTitle("Búsqueda de Remisiones");
                            centerPanelOne.setAutoScroll(true);
                            centerPanelOne.setClosable(true);

                            centerPanelOne.add(generaTabla());

                            centerPanel.add(centerPanelOne);

                            centerPanel.setActiveTab(centerPanel.getComponents().length - 1);
                            panelEstadoDeFuerzaActual.collapse();
                        }


                    }
                }

                public void onFailure(Throwable ex) {
                    notificar(ex.getMessage());
                }
            };




            if (comboSector.getValue() == null && claveSIPTextField.getText().equals("") && folioPuestoMandoTextField.getText().equals("") && avPreviaTextField.getText().equals("") && delitoTextField.getText().equals("")) {
                notificar("Seleccione un Sector en el cual buscar.");
                return;
            }
            buscar = true; //en caso de que alguna validación falle lo ponemos como false para no hacer la busqueda
//            String sector = comboSector.getText();//obtenemos el sector
//            String claveSIP = claveSIPTextField.getText();//obtenemos la clave del SIP
//            String avPrevia = avPreviaTextField.getText();//obtenemos el número de av previa

            if (radioConsultaUnica.isChecked()) {
                if (fechaUnica.getValue().after(new Date())) {
                    notificar("La fecha no puede ser posterior a hoy");
                    buscar = false;
                }
//                if (horaConsultaUnica.getValue() == null) {
//                    notificar("Introduzca una hora de búsqueda");
//                    buscar = false;
//                }
                if (buscar) {


                    bdServiceAsync.buscaRemisiones(
                            radioConsultaRango.isChecked(), radioConsultaUnica.isChecked(),
                            avPreviaTextField.getValueAsString(), claveSIPTextField.getValueAsString(),
                            fechaUnica.getValue(), fechaDesde.getValue(),
                            fechaHasta.getValue(), comboDelegacion.getValue(), comboRegion.getValue(),
                            comboSector.getValue(), folioPuestoMandoTextField.getValueAsString(),
                            checkBoxHoraConsulta4a4.getValue(), callback);
                }
            /*                if (buscar) {

            Date fechaUnicaBusqueda = fechaUnica.getValue();
            String hora = horaConsultaUnica.getValue();
            DateTimeFormat formatter = DateTimeFormat.getFormat("H:m");
            Date horaConsultaUnica = formatter.parse(hora.substring(0, 5));
            fechaUnicaBusqueda.setHours(horaConsultaUnica.getHours());
            fechaUnicaBusqueda.setMinutes(horaConsultaUnica.getMinutes());

            //                    notificar("aquí se hace la busqueda única para la fecha: " + fechaUnicaBusqueda);
            }*/
            } else if (radioConsultaRango.isChecked()) {
                if (fechaHasta.getValue().compareTo(fechaDesde.getValue()) <= 0) {
                    notificar("Por favor introduce dos fechas diferentes\nDonde la primera sea antes que la segunda.");
                    buscar = false;
                }
                if (fechaHasta.getValue().after(new Date())) {
                    notificar("La fecha no puede ser posterior a hoy");
                    buscar = false;
                }
                if (buscar) {
                    bdServiceAsync.buscaRemisiones(
                            radioConsultaRango.isChecked(), radioConsultaUnica.isChecked(),
                            avPreviaTextField.getValueAsString(), claveSIPTextField.getValueAsString(),
                            fechaUnica.getValue(), fechaDesde.getValue(),
                            fechaHasta.getValue(), comboDelegacion.getValue(), comboRegion.getValue(),
                            comboSector.getValue(), folioPuestoMandoTextField.getValueAsString(),
                            checkBoxHoraConsulta4a4.getValue(), callback);
                }
            }
        }
    }

    public void onModuleLoad() {
        Panel panelGeneral = new Panel();
        panelGeneral.setBorder(false);
        panelGeneral.setPaddings(8);
        panelGeneral.setLayout(new FitLayout());

        Panel borderPanelGeneral = new Panel();
        borderPanelGeneral.setLayout(new BorderLayout());

        borderPanelGeneral.setTitle("SSPDF - Consultas PGJ");

        Panel panelMenuBusqueda = new Panel();
        panelMenuBusqueda.setLayout(new RowLayout());
        panelMenuBusqueda.setTitle("Búsqueda");
        panelMenuBusqueda.setCollapsible(true);
        panelMenuBusqueda.setWidth(200);

        Panel accordionBusqueda = new Panel();
        accordionBusqueda.setTitle("Parámetros de búsqueda");
        accordionBusqueda.setBorder(false);
        accordionBusqueda.setIconCls("forlder-icon");
        accordionBusqueda.setAutoScroll(false);


        accordionBusqueda.add(loadBasica());
        panelMenuBusqueda.add(accordionBusqueda);

        BorderLayoutData westData = new BorderLayoutData(RegionPosition.WEST);
        westData.setSplit(true);
        westData.setMinSize(200);
        westData.setMaxSize(400);
        westData.setMargins(new Margins(0, 5, 0, 0));

        borderPanelGeneral.add(panelMenuBusqueda, westData);

        centerPanel = new TabPanel();
        centerPanel.setDeferredRender(false);
        centerPanel.setActiveTab(0);
        centerPanel.setPaddings(15);

        borderPanelGeneral.add(centerPanel, new BorderLayoutData(RegionPosition.CENTER));

        panelGeneral.add(borderPanelGeneral);

        new Viewport(panelGeneral);



    }

    public Panel loadBasica() {
        formPanel = new FormPanel(Position.CENTER);
        formPanel.setFrame(true);
        formPanel.setShadow(true);
        formPanel.setHeader(false);
        formPanel.setWidth(200);
        formPanel.setLabelWidth(85);
        formPanel.setLabelAlign(Position.LEFT);
        //formPanel.setHideLabels(true);
        formPanel.setLabelAlign(Position.LEFT);
        formPanel.setButtonAlign(Position.LEFT);
        fieldSet = new FieldSet();
        fieldSet.setLayout(new FormLayout());
        fieldSet.setButtonAlign(Position.LEFT);
        Store store = new SimpleStore(new String[]{"abbr", "state"}, getHorasBusqueda());
        store.load();

        radioConsultaUnica = new RadioButton("grupo1", "Única Fecha");
        radioConsultaRango = new RadioButton("grupo1", "Rango de Fechas");
        radioConsultaUnica.addClickListener(new ConsultaUnicaListener());
        radioConsultaRango.addClickListener(new ConsultaRangoListener());
        radioConsultaUnica.setChecked(true);


        folioPuestoMandoTextField = new TextField("P. Mando");
        folioPuestoMandoTextField.setWidth(70);
        claveSIPTextField = new TextField("Clave SIP");
        claveSIPTextField.setWidth(70);
        avPreviaTextField = new TextField("Av Previa");
        avPreviaTextField.setWidth(70);
        delitoTextField = new TextField("Delito");
        delitoTextField.setWidth(70);

        fieldSet.add(folioPuestoMandoTextField, new AnchorLayoutData("95%"));
        fieldSet.add(claveSIPTextField, new AnchorLayoutData("95%"));
        fieldSet.add(avPreviaTextField, new AnchorLayoutData("95%"));
        //fieldSet.add(delitoTextField, new AnchorLayoutData("95%"));
        fieldSet.add(radioConsultaUnica);

        Date ahora = new Date();
        fechaUnica = new DateField("Fecha", "fechaUnica", 100);
        fechaUnica.setAllowBlank(false);
        fechaUnica.setValue(ahora);
        fechaUnica.setHideLabel(true);
        fieldSet.add(fechaUnica);

        checkBoxHoraConsulta4a4 = new Checkbox();
        checkBoxHoraConsulta4a4.setLabel("De 4am a 4am");
        checkBoxHoraConsulta4a4.setValue(true);


        //checkBoxHoraConsulta4a4.setWidth(150);



        fieldSet.add(checkBoxHoraConsulta4a4, new AnchorLayoutData("95%"));


        fieldSet.add(radioConsultaRango);
        fechaDesde = new DateField("Desde", "fechaDesde", 100);
        Date desde = new Date();
        desde.setMonth(ahora.getMonth() - 1);
        fechaDesde.setValue(desde);
        fechaDesde.setAllowBlank(false);
        fechaDesde.disable();
        fechaDesde.setHideLabel(true);
        fieldSet.add(fechaDesde);

        fechaHasta = new DateField("Hasta", "fechaHasta", 100);
        fechaHasta.setAllowBlank(false);
        fechaHasta.setValue(ahora);
        fechaHasta.setHideLabel(true);
        fechaHasta.disable();
        fieldSet.add(fechaHasta);


        MessageBox.show(new MessageBoxConfig() {

            {
                setMsg("Cargando Sectores...");
                setProgressText("Cargando Sectores...");
                setWidth(300);
                setWait(true);
                setWaitConfig(new WaitConfig() {

                    {
                        setInterval(2000);
                    }
                });
            }
        });

        System.out.println(">>>>> El bdService: " + bdServiceAsync + " >>>>>>>");

        ((ServiceDefTarget) bdServiceAsync).setServiceEntryPoint(GWT.getModuleBaseURL());



        final AsyncCallback callbackRegiones = new AsyncCallback() {

            public void onSuccess(Object result) {
                MessageBox.hide();
                if (result == null) {
                    notificar("Resultado nulo");
                } else {

                    catalogos = (ArrayList) result;

                    regiones = (Object[][]) catalogos.get(0);
                    delegaciones = (Object[][]) catalogos.get(1);
                    sectores = (Object[][]) catalogos.get(2);

                    regionesStore = new SimpleStore(new String[]{"reg", "region"}, regiones);
                    regionesStore.load();
                    delegacionesStore = new SimpleStore(new String[]{"id", "rid", "delegacion"}, delegaciones);
                    delegacionesStore.load();
                    sectoresStore = new SimpleStore(new String[]{"id2", "did", "sector"}, sectores);
                    sectoresStore.load();

                    comboRegion.setStore(regionesStore);
                    comboDelegacion.setStore(delegacionesStore);
                    comboSector.setStore(sectoresStore);


                }
                //notificar("Success: " + catalogos.size());
                
            }

            public void onFailure(Throwable ex) {
                notificar(ex.getMessage());
            }
        };

        bdServiceAsync.buscaRegiones(callbackRegiones);

        comboRegion = new ComboBox();
        comboRegion.setFieldLabel("Selecciona Region");
        //comboRegion.setStore(regionesStore);
        comboRegion.setDisplayField("region");
        comboRegion.setMode(ComboBox.LOCAL);
        comboRegion.setTriggerAction(ComboBox.ALL);
        comboRegion.setForceSelection(true);
        comboRegion.setValueField("reg");
        comboRegion.setReadOnly(true);
        comboRegion.setWidth(100);
        comboRegion.setEmptyText("REGION");
        comboRegion.setHideLabel(true);

        comboDelegacion = new ComboBox();
        comboDelegacion.setFieldLabel("Seleciona Delegacion");
        //comboDelegacion.setStore(delegacionesStore);
        comboDelegacion.setDisplayField("delegacion");
        comboDelegacion.setValueField("id");
        comboDelegacion.setMode(ComboBox.LOCAL);
        comboDelegacion.setTriggerAction(ComboBox.ALL);
        comboDelegacion.setLinked(true);
        comboDelegacion.setForceSelection(true);
        comboDelegacion.setReadOnly(true);
        comboDelegacion.setWidth(100);
        comboDelegacion.setEmptyText("DELEGACION");
        comboDelegacion.setHideLabel(true);

        comboSector = new ComboBox();
        comboSector.setFieldLabel("Seleciona Sector");
        //comboSector.setStore(sectoresStore);
        comboSector.setDisplayField("sector");
        comboSector.setValueField("id2");
        comboSector.setMode(ComboBox.LOCAL);
        comboSector.setTriggerAction(ComboBox.ALL);
        comboSector.setLinked(true);
        comboSector.setForceSelection(true);
        comboSector.setReadOnly(true);
        comboSector.setWidth(100);
        comboSector.setEmptyText("SECTOR");
        comboSector.setHideLabel(true);

        comboRegion.addListener(new ComboBoxListenerAdapter() {

            @Override
            public void onSelect(ComboBox comboBox, Record record, int index) {
                comboDelegacion.setValue("");
                delegacionesStore.filter("rid", comboBox.getValue());
            }
        });

        comboDelegacion.addListener(new ComboBoxListenerAdapter() {

            public void onSelect(ComboBox comboBox, Record record, int index) {
                comboSector.setValue("");
                sectoresStore.filter("did", comboBox.getValue());
            }
        });

        fieldSet.add(comboRegion);
        fieldSet.add(comboDelegacion);
        fieldSet.add(comboSector);

        formPanel.add(fieldSet);
        Button submitBtn = new Button("Buscar", new BotonBuscarListener());
        formPanel.addButton(submitBtn);
        return formPanel;
    }

    public void notificar(String mensaje) {
        MessageBox mb = new MessageBox();
        mb.alert(mensaje);
    }

    private String[][] getHorasBusqueda() {
        return new String[][]{
                    new String[]{"00:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"01:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"02:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"03:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"04:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"05:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"06:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"07:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"08:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"08:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"10:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"11:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"12:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"13:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"14:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"15:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"16:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"17:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"18:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"19:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"20:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"21:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"22:00 hrs", "00:00", "00:00 hrs"},
                    new String[]{"23:00 hrs", "00:00", "00:00 hrs"}
                };
    }

    private GridPanel generaTabla() {
        RecordDef recordDef = new RecordDef(
                new FieldDef[]{
                    new StringFieldDef("sip"),
                    new StringFieldDef("territorio"),
                    new StringFieldDef("sector"),
                    //                    new DateFieldDef("fecha", "n/j h:ia"),
                    new StringFieldDef("fecha"),
                    new StringFieldDef("avePrevia"),
                    new StringFieldDef("placa"),
                    new StringFieldDef("paternoPolicia"),
                    new StringFieldDef("maternoPolicia"),
                    new StringFieldDef("nombrePolicia"),
                    new StringFieldDef("paternoDetenido"),
                    new StringFieldDef("maternoDetenido"),
                    new StringFieldDef("nombreDetenido"),
                    new StringFieldDef("delito")
                });

        grid = new GridPanel();

        Object[][] data = tablaResultado;
        MemoryProxy proxy = new MemoryProxy(data);

        ArrayReader reader = new ArrayReader(recordDef);
        GroupingStore store = new GroupingStore();
        store.setReader(reader);
        store.setDataProxy(proxy);
        store.setSortInfo(new SortState("sip", SortDir.ASC));
        store.setGroupField("sip");
        store.load();
        grid.setStore(store);


        ColumnConfig[] columns = new ColumnConfig[]{
            //column ID is company which is later used in setAutoExpandColumn
            new ColumnConfig("Folio SIP2", "sip", 60, true, null, "sip"),
            new ColumnConfig("Territorio", "territorio", 50),
            new ColumnConfig("Sector", "sector", 60),
            new ColumnConfig("Fecha", "fecha", 60),
            new ColumnConfig("Averiguación Previa", "avePrevia", 100),
            new ColumnConfig("Placa", "placa", 100, true),
            new ColumnConfig("Paterno Policia", "paternoPolicia", 100, true),
            new ColumnConfig("Materno Policia", "maternoPolicia", 100, true),
            new ColumnConfig("Nombre Policia", "nombrePolicia", 100, true),
            new ColumnConfig("Paterno Detenido", "paternoDetenido", 100, true),
            new ColumnConfig("Materno Detenido", "maternoDetenido", 100, true),
            new ColumnConfig("Nombre Detenido", "nombreDetenido", 100, true),
            new ColumnConfig("Delito", "delito", 100, true),};


        GroupingView gridView = new GroupingView();
        gridView.setForceFit(true);
        gridView.setGroupTextTpl("{text} ({[values.rs.length]} {[values.rs.length > 1 ? " +
                "\"Remisiones\" : \"Remision\"]})");

        ColumnModel columnModel = new ColumnModel(columns);
        grid.setView(gridView);
        grid.setColumnModel(columnModel);
        grid.setFrame(true);
        grid.setStripeRows(true);
//        grid.setAutoExpandColumn("sip");
//        grid.setAutoExpandColumn("territorio");
//        grid.setAutoExpandColumn("sector");
//        grid.setAutoExpandColumn("fecha");
//        grid.setAutoExpandColumn("avePrevia");
//        grid.setAutoExpandColumn("paternoPolicia");
//        grid.setAutoExpandColumn("maternoPolicia");
//        grid.setAutoExpandColumn("nombrePolicia");
//        grid.setAutoExpandColumn("paternoDetenido");
//        grid.setAutoExpandColumn("maternoDetenido");
//        grid.setAutoExpandColumn("nombreDetenido");
//        grid.setAutoExpandColumn("delito");

        grid.setHeight(600);
        grid.setWidth(900);
        grid.setAutoScroll(true);
        grid.setTitle("Remisiones");

//        Toolbar bottomToolbar = new Toolbar();
//        bottomToolbar.addFill();
////        //bottomToolbar.addButton(new ToolbarButton("Quita Ordenamiento", new ButtonListenerAdapter() {
////
////            public void onClick(Button button, EventObject e) {
////                grid.clearSortState(true);
////            }
////        }));
//        grid.setBottomToolbar(bottomToolbar);

        return grid;
    }
}
