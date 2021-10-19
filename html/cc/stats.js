function onsliderinput_handle(id) {
  const value = window["chart" + id + "value"];
  const slider = window["chart" + id + "slider"];
  if (slider === undefined || value === undefined) return;

  value.innerHTML = slider.value + "  ";
  if (slider.value !== window["last_chart" + id + "value"] && value.parentElement.children.length === 1) {
    const button = document.createElement("button");
    button.style.marginLeft = "auto";
    button.innerHTML = "berechnen";
    button.onclick = () => {
      button.onclick = undefined;
      window["last_chart" + id + "value"] = slider.value;
      window["update_chart" + id]();
      button.remove();
    };
    value.parentElement.appendChild(button);
  }
}

function init_chart(id, max, init_value, data_function, update_function) {
  const charts_div = document.getElementById("charts");

  window["chart" + id + "_exists"] = true;
  window["chart" + id] = undefined;
  window["last_chart" + id + "value"] = init_value;
  window["chart" + id + "_data"] = data_function;
  window["update_chart" + id] = update_function;

  const chart_div = document.createElement("div");
  chart_div.style = "width: 100%; display: flex; flex-direction: row;";

  const chart_value = document.createElement("h2");
  chart_value.innerHTML = init_value;
  window["chart" + id + "value"] = chart_value;

  const chart_slider = document.createElement("input");
  chart_slider.min = 1;
  chart_slider.max = max;
  chart_slider.type = "range";
  chart_slider.value = init_value;
  chart_slider.classList.add("slider");
  chart_slider.oninput = () => onsliderinput_handle(id);
  window["chart" + id + "slider"] = chart_slider;

  const chart = document.createElement("canvas");
  chart.id = "chart" + 1;
  window["chart" + id + "canvas"] = chart;

  chart_div.appendChild(chart_value);
  charts_div.appendChild(chart_div);
  charts_div.appendChild(chart_slider);
  charts_div.appendChild(chart);
}

async function update_chart(id, type, color, label, tooltip_function) {
  const data = window["chart" + id + "_data"](window["last_chart" + id + "value"]);
  if (window["chart" + id] !== undefined) window["chart" + id].destroy();
  window["chart" + id] = new Chart(window["chart" + id + "canvas"], {
    type: type,
    data: {
      labels: Array.from(data.keys()),
      datasets: [
        {
          label: label,
          data: Array.from(data.values()),
          backgroundColor: color,
        },
      ],
    },
    options: {
      scales: {
        yAxes: [{ gridLines: { color: "#ffffff" } }],
        xAxes: [{ gridLines: { color: "#3a3a3a" } }],
      },
      tooltips: {
        callbacks: {
          title: (data) => data[0].xLabel + ", " + data[0].yLabel,
          label: tooltip_function,
        },
      },
    },
  });
}
