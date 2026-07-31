/**
 * Mesa de Datos · Plan Estadístico Territorial de Ibagué
 * Recibe los formularios diligenciados y los guarda en esta hoja de cálculo.
 *
 * INSTALACIÓN (una sola vez, unos 10 minutos)
 * -------------------------------------------------------------------------
 * 1. Cree una hoja de cálculo nueva en Google Drive, con la cuenta
 *    institucional. Nómbrela, por ejemplo, "PET Ibagué · Base de datos".
 * 2. Menú Extensiones → Apps Script. Borre lo que aparezca y pegue este
 *    archivo completo.
 * 3. Cambie la palabra clave de la línea siguiente por una propia.
 * 4. Botón "Implementar" → "Nueva implementación" → tipo "Aplicación web".
 *      Ejecutar como:        Yo
 *      Quién tiene acceso:   Cualquier usuario
 *    Autorice cuando lo pida. Copie la URL que termina en /exec.
 * 5. En la aplicación, pestaña "Consolidado y exportación", elija destino
 *    "sheets", pegue la URL y la palabra clave, y guarde la conexión.
 *
 * Cada formato del DANE crea su propia pestaña. Si un funcionario corrige y
 * vuelve a guardar, la fila se actualiza en lugar de duplicarse.
 */

var CLAVE = 'ibague2026';   // <-- cámbiela

function doPost(e) {
  try {
    var d = JSON.parse(e.postData.contents);
    if (d.token !== CLAVE) return responder({ok: false, error: 'Clave incorrecta'});

    var libro = SpreadsheetApp.getActiveSpreadsheet();
    var nombreHoja = (d.formatoNombre || d.formato || 'Datos').substring(0, 90);
    var hoja = libro.getSheetByName(nombreHoja);

    if (!hoja) {
      hoja = libro.insertSheet(nombreHoja);
      hoja.appendRow(d.columnas);
      hoja.setFrozenRows(1);
      hoja.getRange(1, 1, 1, d.columnas.length)
          .setFontWeight('bold').setBackground('#1E3D50').setFontColor('#FFFFFF');
    }

    // Si el esquema creció, amplía el encabezado sin perder lo ya guardado.
    var anchoActual = hoja.getLastColumn();
    if (d.columnas.length > anchoActual) {
      hoja.getRange(1, 1, 1, d.columnas.length).setValues([d.columnas]);
    }

    var fila = buscarFila(hoja, d.id);
    if (fila > 0) {
      hoja.getRange(fila, 1, 1, d.fila.length).setValues([d.fila]);
      return responder({ok: true, accion: 'actualizado', fila: fila});
    }
    hoja.appendRow(d.fila);
    return responder({ok: true, accion: 'agregado', fila: hoja.getLastRow()});

  } catch (err) {
    return responder({ok: false, error: String(err)});
  }
}

function buscarFila(hoja, id) {
  if (hoja.getLastRow() < 2) return -1;
  var ids = hoja.getRange(2, 1, hoja.getLastRow() - 1, 1).getValues();
  for (var i = 0; i < ids.length; i++) {
    if (String(ids[i][0]) === String(id)) return i + 2;
  }
  return -1;
}

function responder(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function doGet() {
  return responder({ok: true, servicio: 'Mesa de Datos · PET Ibagué'});
}
