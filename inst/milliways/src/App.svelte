<script>
	import Interface from "./components/Interface.svelte";

  // datasets (for the milliways-r pkg)
  import * as results from '../static/data/results.json'; 
  import * as code from '../static/data/code.json';
  import * as tableData from '../static/data/input-data.json';
  
  let emar = 'analysis-doc.html';
</script>

<main>
	<Interface data={results.default} code={code} tableData={tableData.default} emar={emar}/>
</main>