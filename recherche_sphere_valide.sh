pMEFPP=$3
pPrefixe=$1
pMaillageBasePrefixe=$2

echo "MEFPP commande: ${MEFPP}"
echo "Préfixe: ${pPrefixe}"
echo "Maillages: ${pMaillageBasePrefixe}"

lRayon=2661
lMailles=(16, 32, 64, 128, 256)
lNbEssais=50
# Varie le rayon à chaque itération; et découpe chaque maillage
for (( i=0; $i < $lNbEssais; i++ )) do
	sed -i "s/scalaire r0 .*/scalaire r0 0.0${lRayon}" "${pPrefixe}.champs"
	for (( i=0; $i < ${#files[@]}; i++ )) do
		ln -sf "${lMaillageBasePrefixe}${lMailles[$i]}.champs" "${pPrefixe}.champs"
		$pMEFPP $pPrefixe |& tee .mefppout
	done
	# Vérifie la sortie écran et quitte si aucune instersection invalide détectée
	if ! grep -q "intersection" .mefppout; then
		echo "Sphere valide r=${lRayon}"
		exit 0
	fi

	lRayon=$(( $lRayon + 1 ))
done

